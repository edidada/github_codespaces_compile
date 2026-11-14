#!/usr/bin/env bash
#
# herdr（herdrdev/herdr，Rust 单二进制 TUI 终端复用器）release 构建。
# 上游 README：cargo build --release；rust-toolchain.toml=1.96.1。
# herdr 自称 "one rust binary, no electron" —— release 二进制即完整产物，
# 没有额外的 GUI 打包步骤。多 OS / 多 CPU 矩阵的每条腿各自在本机原生编译。
set -euo pipefail

WORK_DIR="$(pwd)/_herdr_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/herdr"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"

echo "==== 0. 宿主环境 ===="
uname -a
rustc --version
cargo --version

echo "==== 1. 取源码（master 浅克隆，保留 LF）===="
git -c core.autocrlf=false clone --quiet --depth=1 --branch master https://github.com/herdrdev/herdr.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"

echo "==== 2. cargo build --release ===="
build_log="$LOG_DIR/cargo-build.log"
if ! cargo build --release --locked >"$build_log" 2>&1; then
    tail -n 120 "$build_log"
    echo "FATAL: herdr release 编译失败" >&2
    exit 1
fi
tail -n 10 "$build_log" || true

echo "==== 3. 收集产物 ===="
OUT=""
for f in target/release/herdr target/release/herdr.exe; do
    if [ -f "$f" ]; then
        cp "$f" "$ART_DIR/"
        OUT="$(basename "$f")"
    fi
done
[ -n "$OUT" ] || { echo "FATAL: 没有产出 herdr 二进制" >&2; exit 1; }
{
    echo "project=herdrdev/herdr"
    echo "commit=$commit"
    echo "os=$OS"
    echo "arch=$ARCH"
    echo "rust=$(rustc --version)"
} >"$ART_DIR/build-info.txt"
echo "PASS: $OUT"
ls -la "$ART_DIR"
