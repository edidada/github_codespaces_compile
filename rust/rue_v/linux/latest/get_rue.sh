#!/usr/bin/env bash
#
# Rue（rue-language/rue）：Rust 实现的实验性系统语言，Buck2 + DotSlash 构建，
# 不依赖 LLVM，自带 x86-64/aarch64 原生代码生成（ELF/Mach-O）。
# 上游 ci.yml 的 native-platforms leg 只覆盖 ubuntu-24.04-arm 与 macos-15；
# 本脚本把同一套 `buck2 build //crates/rue:rue` 搬到 5 条能支撑目标平台的腿上。
# 端到端：装 dotslash → 编出 Rue 编译器 → 用编译器把 welcome.rue 编成原生可执行并运行。
set -euo pipefail

WORK_DIR="$(pwd)/_rue_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/rue"
BIN_DIR="$WORK_DIR/bin"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR" "$BIN_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"
echo "==== 0. 宿主环境 ===="
uname -a

echo "==== 1. 安装 DotSlash（Buck2 引导器，全平台静态二进制）===="
DS_VER="v0.5.9"
case "$OS:$ARCH" in
  Linux:x86_64)          DS_ASSET="dotslash-linux-musl.x86_64.tar.gz" ;;
  Linux:aarch64|Linux:arm64) DS_ASSET="dotslash-linux-musl.aarch64.tar.gz" ;;
  Darwin:arm64)          DS_ASSET="dotslash-macos-arm64.tar.gz" ;;
  Darwin:x86_64)         DS_ASSET="dotslash-macos-x86_64.tar.gz" ;;
  *) echo "FATAL: 未支持的 dotslash 平台 $OS/$ARCH" >&2; exit 1 ;;
esac
curl -fsSL --retry 3 "https://github.com/facebook/dotslash/releases/download/$DS_VER/$DS_ASSET" \
  -o "$WORK_DIR/dotslash.tar.gz"
tar -xzf "$WORK_DIR/dotslash.tar.gz" -C "$BIN_DIR"
DS_BIN="$(find "$BIN_DIR" -type f -name 'dotslash' -perm -u+x | head -1)"
if [ -z "$DS_BIN" ]; then
  echo "FATAL: dotslash 解压后未找到可执行文件，归档内容：" >&2
  tar -tzf "$WORK_DIR/dotslash.tar.gz" | head -20 >&2
  exit 1
fi
chmod +x "$DS_BIN"
export PATH="$(dirname "$DS_BIN"):$PATH"
dotslash --version || true
echo "PASS: dotslash 就位 $DS_BIN"

echo "==== 2. 取源码（trunk 浅克隆，保留 LF）===="
git -c core.autocrlf=false clone --quiet --depth=1 --branch trunk \
  https://github.com/rue-language/rue.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"

echo "==== 3. Buck2 编译 Rue 编译器 ===="
# 不走远程缓存（没有 BuildBuddy key 时本地构建即可），避免私有 cache 配置报错。
export RUE_NO_REMOTE_CACHE=1
build_log="$LOG_DIR/rue-build.log"
path_file="$LOG_DIR/rue-bin-path.txt"
if ! scripts/rue-bin >"$path_file" 2>"$build_log"; then
  echo "FATAL: Rue 编译器构建失败，日志尾部：" >&2
  tail -n 150 "$build_log" >&2
  exit 1
fi
tail -n 10 "$build_log" || true
RUE_BIN="$(tail -n 1 "$path_file" | tr -d '\r')"
if [ -z "$RUE_BIN" ] || [ ! -x "$RUE_BIN" ]; then
  echo "FATAL: 编译器路径无效: '$RUE_BIN'" >&2
  exit 1
fi
echo "PASS: 编译器就位 $RUE_BIN"

echo "==== 4. 端到端：用 Rue 编译器把 welcome.rue 编成原生可执行并运行 ===="
if ! "$RUE_BIN" examples/welcome.rue -o "$ART_DIR/welcome" >"$LOG_DIR/compile.log" 2>&1; then
  cat "$LOG_DIR/compile.log" >&2
  echo "FATAL: welcome.rue 编译失败" >&2
  exit 1
fi
if [ ! -x "$ART_DIR/welcome" ]; then
  echo "FATAL: 未生成 welcome 可执行" >&2
  exit 1
fi
prog_out="$("$ART_DIR/welcome" 2>&1)" || {
  echo "FATAL: welcome 运行失败: $prog_out" >&2
  exit 1
}
echo "welcome 输出: $prog_out"
if ! printf '%s\n' "$prog_out" | grep -q '42'; then
  echo "FATAL: welcome 输出异常（未见 42）" >&2
  exit 1
fi

echo "==== 5. 收集产物 ===="
cp "$RUE_BIN" "$ART_DIR/rue"
{
  echo "project=rue-language/rue"
  echo "commit=$commit"
  echo "os=$OS"
  echo "arch=$ARCH"
  echo "dotslash=$DS_VER"
  echo "welcome-output=$prog_out"
} >"$ART_DIR/build-info.txt"
echo "PASS: 编译器 + welcome 原生可执行"
ls -la "$ART_DIR"
