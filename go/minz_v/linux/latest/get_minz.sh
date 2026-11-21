#!/usr/bin/env bash
#
# MinZ（oisee/minz）：纯 Go 的 Z80 现代语言编译器工具链（mz 编译器 / mza 汇编器 /
# mze 模拟器），支持 Nanz/C89/Pascal/Frill 等前端，极小目标后端代表。无外部依赖。
# 端到端：go build 出 mz/mza/mze → mz 把 Nanz hello 编成 Z80 汇编 → mza 汇编成 CP/M .com
# → mze 模拟器运行输出 "Hello!"（Windows 腿例外：上游 mze 的 syscall 不兼容 Windows，
#   故 Windows 只编 mz+mza，验证到产出有效 .com 为止）。
set -euo pipefail

WORK_DIR="$(pwd)/_minz_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/minz"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"
WIN=0
case "$OS" in
  MINGW*|MSYS*|CYGWIN*|Windows_NT) WIN=1 ;;
esac
EXT=""
[ "$WIN" -eq 1 ] && EXT=".exe"
echo "==== 0. 宿主环境 ===="
uname -a
command -v go >/dev/null 2>&1 || { echo "FATAL: go 未安装" >&2; exit 127; }
go version

echo "==== 1. 取源码（最新 tag v0.25.4，浅克隆）===="
git -c core.autocrlf=false clone --quiet --depth=1 --branch v0.25.4 \
  https://github.com/oisee/minz.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
tag="$(git describe --tags --abbrev=0)"
echo "PASS: 源码就位 commit=$commit tag=$tag"

echo "==== 2. go build 工具链（mz / mza / mze）===="
cd "$SRC_DIR/minzc"
mkdir -p "$ART_DIR"
build_one() {
  name="$1"; pkg="$2"
  if ! go build -o "$ART_DIR/${name}${EXT}" "$pkg" >"$LOG_DIR/build-$name.log" 2>&1; then
    cat "$LOG_DIR/build-$name.log" >&2
    echo "FATAL: go build $name 失败" >&2
    exit 1
  fi
  echo "PASS: 构建 $name${EXT}"
}
build_one mz ./cmd/minzc
build_one mza ./cmd/mza
if [ "$WIN" -eq 1 ]; then
  echo "SKIP: Windows 平台上游 mze 依赖 syscall.FdSet/Select（Windows 不支持），跳过模拟器"
else
  build_one mze ./cmd/mze
fi
cd "$SRC_DIR"
MZ="$ART_DIR/mz${EXT}"
MZA="$ART_DIR/mza${EXT}"
MZE="$ART_DIR/mze${EXT}"

echo "==== 3. 端到端：Nanz → Z80 汇编 → CP/M .com ====="
EX="examples/nanz/hello_cpm.nanz"
[ -f "$SRC_DIR/$EX" ] || EX="examples/cpm/hello_cpm.minz"
[ -f "$SRC_DIR/$EX" ] || { echo "FATAL: 找不到 hello 示例" >&2; exit 1; }
if ! "$MZ" "$EX" --target cpm -o "$ART_DIR/hello.a80" >"$LOG_DIR/compile.log" 2>&1; then
  cat "$LOG_DIR/compile.log" >&2
  echo "FATAL: mz 编译失败" >&2
  exit 1
fi
if ! "$MZA" "$ART_DIR/hello.a80" -o "$ART_DIR/hello.com" >>"$LOG_DIR/compile.log" 2>&1; then
  cat "$LOG_DIR/compile.log" >&2
  echo "FATAL: mza 汇编失败" >&2
  exit 1
fi
[ -s "$ART_DIR/hello.com" ] || { echo "FATAL: hello.com 为空" >&2; exit 1; }
echo "PASS: hello.com $(wc -c < "$ART_DIR/hello.com") bytes"

EMU_INFO="skipped (windows mze not supported upstream)"
if [ "$WIN" -ne 1 ]; then
  echo "==== 4. mze 模拟器运行 ====="
  emu_out="$("$MZE" "$ART_DIR/hello.com" -t cpm 2>&1)" || {
    echo "FATAL: mze 模拟器运行失败: $emu_out" >&2
    exit 1
  }
  echo "模拟器输出: $emu_out"
  if ! printf '%s\n' "$emu_out" | grep -qi 'hello'; then
    echo "FATAL: 模拟器输出异常（未见 Hello）" >&2
    exit 1
  fi
  EMU_INFO="$emu_out"
fi

echo "==== 5. 收集产物 ===="
{
  echo "project=oisee/minz"
  echo "commit=$commit"
  echo "tag=$tag"
  echo "os=$OS"
  echo "arch=$ARCH"
  echo "go=$(go version)"
  echo "emulator-output=$EMU_INFO"
} >"$ART_DIR/build-info.txt"
echo "PASS: 编译器/汇编器 + CP/M Z80 目标产物"
ls -la "$ART_DIR"
