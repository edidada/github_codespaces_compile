#!/usr/bin/env bash
#
# Cowgol（davidgiven/cowgol）：自举的极小目标后端语言，编译器本身用 Cowgol 写成，
# 8080/Z80/6502/68000/80386/ARM/PowerPC 等微目标后端。上游明确 Unixish/Linux-only。
# 端到端：apt 依赖（PPA 可选，config.py 按可用工具裁剪后端）→ make 自举
# （bootstrap→ncgen→nncgen）→ 运行 nncgen 自举编译器编出的 helloworld（纯 C 后端，
# 不依赖任何交叉汇编器，故 Ubuntu 22/24/26 + arm64 四腿都能产出并运行）。
set -euo pipefail

WORK_DIR="$(pwd)/_cowgol_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/cowgol"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"
echo "==== 0. 宿主环境 ===="
uname -a

echo "==== 1. apt 安装构建依赖 ===="
export DEBIAN_FRONTEND=noninteractive
SUDO=""
if [ "$(id -u)" -ne 0 ]; then SUDO="sudo"; fi
$SUDO apt-get update -qq >"$LOG_DIR/apt.log" 2>&1 || true
# PPA 提供 binutils-m68k-atari-mint；26.04/arm64 上可能没有对应包，失败不影响核心自举。
$SUDO add-apt-repository -y ppa:vriviere/ppa >>"$LOG_DIR/apt.log" 2>&1 || true
$SUDO apt-get update -qq >>"$LOG_DIR/apt.log" 2>&1 || true
# 核心：Lua 5.1 / Python3 / chronic(moreutils) / flex / bison / libbsd / readline /
# ninja / gpp / libz80ex（cpmemu）/ 交叉 binutils / nasm / 64tass / qemu-user。
PKGS="moreutils lua5.1 python3 ninja-build flex bison libbsd-dev libreadline-dev \
      libz80ex-dev gpp nasm 64tass qemu-user \
      binutils-i686-linux-gnu binutils-arm-linux-gnueabihf binutils-powerpc-linux-gnu \
      binutils-m68k-linux-gnu libfl-dev"
# 可选包逐个装，缺失不致命（config.py 会跳过依赖它们的后端）。
for p in $PKGS; do
  if ! $SUDO apt-get install -y --no-install-recommends "$p" >>"$LOG_DIR/apt.log" 2>&1; then
    echo "WARN: 可选依赖 $p 安装失败，跳过对应后端" >&2
  fi
done
# Atari/Amiga 交叉汇编器若可用则补上（有则多两个后端）。
$SUDO apt-get install -y --no-install-recommends binutils-m68k-atari-mint >>"$LOG_DIR/apt.log" 2>&1 || true
tail -n 8 "$LOG_DIR/apt.log" || true
command -v lua5.1 >/dev/null && echo "PASS: lua5.1 就位" || echo "WARN: lua5.1 缺失"
command -v ninja >/dev/null && echo "PASS: ninja 就位" || echo "WARN: ninja 缺失"

echo "==== 2. 取源码（master 浅克隆，保留 LF）===="
git -c core.autocrlf=false clone --quiet --depth=1 --branch master \
  https://github.com/davidgiven/cowgol.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"

echo "==== 3. make 自举（bootstrap → ncgen → nncgen）===="
# GCC 15（Ubuntu 26.04 默认）以 C23 为默认标准，third_party/zmac 的 K&R 老代码里
# bookmark()/getlocal() 空参数列表会被当成"无参"而报 too many arguments/conflicting types。
# 仅当 GCC 主版本 >= 15 时显式固定到 gnu17（GCC 11/13 的默认标准，既兼容 zmac 的 K&R
# 又支持 rt/cgen/cowgol.h 的 C99 for 声明），不影响 gcc 11/13 的 22.04/24.04/arm 腿。
GCC_MAJ="$(gcc -dumpversion 2>/dev/null | cut -d. -f1)"
echo "GCC major: ${GCC_MAJ:-unknown}"
NPROC="$( (command -v nproc >/dev/null && nproc) || echo 4 )"
NEED_GNU89=0
if [ -n "$GCC_MAJ" ] && [ "$GCC_MAJ" -ge 15 ] 2>/dev/null; then NEED_GNU89=1; fi
if [ "$NEED_GNU89" -eq 1 ]; then
  # GCC 15 默认 C23：zmac 的 K&R 空参数列表会被当无参而报错；但 gnu89 又太老，
  # rt/cgen/cowgol.h 用了 C99 的 for 循环声明。gnu17 是 GCC 11/13（已通过的腿）的
  # 默认标准，既兼容 zmac 的 K&R 又支持 for 声明。显式指定覆盖 C23 默认值即可。
  # zmac 是 host 工具用 $(HOSTCFLAGS)，其余用 $(CFLAGS)；make 命令行变量优先级最高。
  echo "GCC>=15: CFLAGS/HOSTCFLAGS 固定 gnu17"
  if ! make -j"$NPROC" CFLAGS="-std=gnu17 -g -Og" HOSTCFLAGS="-std=gnu17 -g -Og" >"$LOG_DIR/make.log" 2>&1; then
    echo "FATAL: Cowgol make 失败，日志尾部：" >&2
    tail -n 180 "$LOG_DIR/make.log" >&2
    exit 1
  fi
elif ! make -j"$NPROC" >"$LOG_DIR/make.log" 2>&1; then
  echo "FATAL: Cowgol make 失败，日志尾部：" >&2
  tail -n 180 "$LOG_DIR/make.log" >&2
  exit 1
fi
tail -n 15 "$LOG_DIR/make.log" || true
echo "PASS: make 完成"

echo "==== 4. 端到端：运行自举编译器编出的 helloworld（C 后端）===="
HELLO=""
for cand in bin/examples/helloworld-for-nncgen bin/examples/helloworld-for-nncgen.exe \
            bin/examples/helloworld-for-ncgen bin/examples/helloworld-for-ncgen.exe; do
  if [ -x "$SRC_DIR/$cand" ]; then HELLO="$SRC_DIR/$cand"; break; fi
done
if [ -z "$HELLO" ]; then
  echo "可用 helloworld 产物：" >&2
  ls -la "$SRC_DIR/bin/examples/" 2>/dev/null | head -30 >&2 || true
  echo "FATAL: 未找到可执行的 helloworld 产物" >&2
  exit 1
fi
hello_out="$("$HELLO" 2>&1)" || {
  echo "FATAL: helloworld 运行失败: $hello_out" >&2
  exit 1
}
echo "helloworld 输出: $hello_out"
if ! printf '%s\n' "$hello_out" | grep -qi 'hello'; then
  echo "FATAL: helloworld 输出异常" >&2
  exit 1
fi

echo "==== 5. 收集产物（自举出的全套交叉编译器）===="
tar -czf "$ART_DIR/cowgol-bin.tar.gz" -C "$SRC_DIR" bin
cp "$HELLO" "$ART_DIR/helloworld" 2>/dev/null || true
{
  echo "project=davidgiven/cowgol"
  echo "commit=$commit"
  echo "os=$OS"
  echo "arch=$ARCH"
  echo "hello-output=$hello_out"
} >"$ART_DIR/build-info.txt"
echo "PASS: 自举编译器 + helloworld"
ls -la "$ART_DIR"
