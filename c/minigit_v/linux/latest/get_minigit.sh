#! /bin/bash
# DQNEO/minigit（教学版迷你 git）源码编译 + 与真 git 交叉验证。
#
# 2026-10-24（workflow 从已下线的 ubuntu-20.04 换成 ubuntu-latest 后，run 40056373248 失败）。
# 这一步其实从来没过，两条都是上游自身的坑，旧脚本原样照抄了它们：
#
# (1) 上游 Makefile 把链接库放在了源文件之前：
#       gcc -g3 -Wall -O0  -lz -lssl -lcrypto -o minigit minigit.c zlib.c sha1.c time.c $(SUBCOMMANDS)
#     GNU ld 按从左到右的顺序解析，共享库出现在“引用它的目标文件”之前时不会带入任何符号，
#     于是 inflateInit_ / inflate / deflate / SHA1_Init 全部 undefined：
#       /usr/bin/ld: .../minigit/zlib.c:27:(.text+0x111): undefined reference to `inflateInit_'
#       collect2: error: ld returned 1 exit status
#
# (2) 上游 Makefile 根本没有 install 目标：
#       make: *** No rule to make target 'install'.  Stop.
#
# 这里不改上游 Makefile（保持“原代码行不删”），只是不再走 `make` 的链接命令，
# 用完全相同的编译/链接选项手工按正确顺序链接，并把“安装”落成一条 install 命令。
# 另外 OpenSSL 3（noble 默认）里 SHA1_Init 仍可用，只是低层 API 已不推荐 —— 下面实测确实能链接。
set -euo pipefail
cd "$(dirname "$0")"

WORK_DIR="$(pwd)/.work"
rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"

echo "==== 1. 依赖 ===="
sudo apt-get update -qq
sudo apt-get install -y -qq build-essential git zlib1g-dev libssl-dev

echo "==== 2. 取源码 ===="
rm -rf minigit
git clone -q --depth 1 https://github.com/DQNEO/minigit.git
cd minigit
echo "HEAD=$(git rev-parse --short HEAD)  ($(git log -1 --format=%cd --date=short))"
echo "---- 上游链接命令（问题所在，原样保留供对照）----"
grep -n 'gcc' Makefile

echo "==== 3. 按正确的链接顺序构建 ===="
gcc -g3 -Wall -O0 -o minigit minigit.c zlib.c sha1.c time.c cmd/*.c -lz -lssl -lcrypto
file minigit
echo "---- 确认 zlib / libcrypto 真的链进来了 ----"
ldd minigit | grep -E 'libz\.so|libcrypto\.so' || { echo "FATAL: 没链上 zlib/libcrypto" >&2; exit 1; }

echo "==== 4. 安装（上游没有 install 目标，这里显式安装）===="
sudo install -m 0755 minigit /usr/local/bin/minigit
command -v minigit
./minigit --version
minigit --version   # 装到 PATH 的那份也要能跑

echo "==== 5. 功能实测：init ===="
TMP="$(mktemp -d)"
cd "$TMP"
minigit init
[ -d .git ]          || { echo "FATAL: minigit init 没建 .git" >&2; exit 1; }
[ -d .git/objects ]  || { echo "FATAL: 缺 .git/objects" >&2; exit 1; }
[ -d .git/refs ]     || { echo "FATAL: 缺 .git/refs" >&2; exit 1; }
head_c="$(cat .git/HEAD)"
echo ".git/HEAD = [$head_c]"
[ "$head_c" = "ref: refs/heads/master" ] || { echo "FATAL: .git/HEAD 内容不对" >&2; exit 1; }
echo "PASS: minigit init 的目录结构与 HEAD 内容符合上游 cmd/init.c 的实现"

echo "==== 6. 功能实测：hash-object 与真 git 交叉验证 ===="
printf 'hello minigit\n' > probe.txt
want_size="$(stat -c%s probe.txt)"
# git 的 blob 对象哈希 = sha1("blob <字节数>\0<内容>")，这里独立算一遍当第三个参照
calc="$( { printf 'blob %s\0' "$want_size"; cat probe.txt; } | sha1sum | cut -d' ' -f1 )"
# 真 git 不能直接在 minigit 建出来的 .git 里跑，所以另开一个 git init 的目录放同一份文件
CROSS="$(mktemp -d)"
git init -q "$CROSS"
cp probe.txt "$CROSS/probe.txt"
real="$(git -C "$CROSS" hash-object probe.txt)"
mine="$(minigit hash-object probe.txt)"
echo "minigit   = $mine"
echo "真 git    = $real"
echo "自算 sha1 = $calc"
[ "$mine" = "$real" ]  || { echo "FATAL: minigit 的 blob 哈希与真 git 不一致" >&2; exit 1; }
[ "$mine" = "$calc" ]  || { echo "FATAL: minigit 的 blob 哈希与自算 sha1 不一致" >&2; exit 1; }
rm -rf "$CROSS"
echo "PASS: 同一个 blob 的哈希，minigit / 真 git / 独立 sha1 计算三方一致"

echo "==== 7. 功能实测：hash-object -w 写松散对象，再 cat-file 读回 ===="
sha="$(minigit hash-object -w probe.txt | tr -d '[:space:]')"
echo "写入对象 $sha"
obj=".git/objects/${sha:0:2}/${sha:2}"
[ -f "$obj" ] || { echo "FATAL: 没写出松散对象 $obj" >&2; exit 1; }
ls -l "$obj"
# 对象内容应是 zlib 压缩的 "blob <size>\0<内容>"，用 python 独立解一遍
python3 - "$obj" "probe.txt" <<'PY'
import sys, zlib
raw = zlib.decompress(open(sys.argv[1], 'rb').read())
body = open(sys.argv[2], 'rb').read()
expect = b'blob %d\0' % len(body) + body
assert raw == expect, f"对象内容不符: 实际 {raw!r} 期望 {expect!r}"
print(f"PASS: 松散对象解压后正是 {expect!r}（minigit 的 zlib 写入格式与 git 一致）")
PY
read_back="$(minigit cat-file -p "$sha")"
echo "cat-file -p 读回: [$read_back]"
[ "$read_back" = "$(cat probe.txt)" ] || { echo "FATAL: cat-file -p 读回内容与原文件不一致" >&2; exit 1; }
size_back="$(minigit cat-file -s "$sha" | tr -d '[:space:]')"
[ "$size_back" = "$want_size" ] || { echo "FATAL: cat-file -s 报的 size 是 $size_back，期望 $want_size" >&2; exit 1; }
echo "PASS: 写进去的松散对象能被 minigit 自己读回（-p 内容、-s 大小都对）"
cd /
rm -rf "$TMP"
echo "==== minigit 构建与功能校验全部通过 ===="
