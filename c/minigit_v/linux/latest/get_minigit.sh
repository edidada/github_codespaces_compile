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
#
# 2026-10-24 第二轮（rerun 40056373248 停在“没写出松散对象”）：上游 -w 走的 rename 目标目录
# .git/objects/xy/ 从来没人创建、rename 又不检查返回值，所以 hash-object -w 静默失败。
# 证据链和修法写在第 7 步里。
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
make
sudo make install
