#!/usr/bin/env bash
#
# magpie（yetone/magpie，Go + Wails v3 桌面网关）GUI 打包。
# 上游 Makefile 的 build-release = assets-pack + go build -tags "production [gtk3] packedassets"。
#   - Linux：Wails v3 的 GTK3 / WebKitGTK 4.1 路径（-tags gtk3，需 headers），
#     pkg-config 要求 gtk+-3.0 / webkit2gtk-4.1 / libsoup-3.0。
#   - Windows：WebView2，CGO_ENABLED=0，-H windowsgui 打成 GUI 程序。
#   - macOS：WKWebView，cgo + Xcode clang，runner 自带。
# 多 OS / 多 CPU 矩阵的每条腿各自在本机原生编译，产出 GUI 二进制。
set -euo pipefail

WORK_DIR="$(pwd)/_magpie_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/magpie"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"

echo "==== 0. 宿主环境 ===="
uname -a
go version

echo "==== 1. 取源码（main 浅克隆，保留 LF）===="
git -c core.autocrlf=false clone --quiet --depth=1 https://github.com/yetone/magpie.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"

echo "==== 2. 打包 GUI 资源（assets.zip）===="
go run ./build/assetpack internal/gui/assets internal/gui/assets.zip

TAGS="production packedassets"
LDFLAGS="-s -w -X main.version=dev"
OUT="magpie"

echo "==== 3. 按 OS 准备 GUI 依赖 ===="
case "$OS" in
    Linux)
        sudo apt-get update -qq
        sudo apt-get install -y --no-install-recommends \
            libgtk-3-dev libwebkit2gtk-4.1-dev libsoup-3.0-dev
        TAGS="$TAGS gtk3"
        ;;
    MINGW* | MSYS* | CYGWIN*)
        export CGO_ENABLED=0
        LDFLAGS="$LDFLAGS -H windowsgui"
        OUT="magpie.exe"
        ;;
    Darwin)
        ;;
esac

echo "==== 4. 编译 GUI 二进制（tags: $TAGS）===="
build_log="$LOG_DIR/go-build.log"
if ! go build -tags "$TAGS" -trimpath -ldflags "$LDFLAGS" -o "$ART_DIR/$OUT" . >"$build_log" 2>&1; then
    tail -n 120 "$build_log"
    echo "FATAL: magpie GUI 编译失败" >&2
    exit 1
fi
tail -n 5 "$build_log" || true

echo "==== 5. 收集产物 ===="
{
    echo "project=yetone/magpie"
    echo "commit=$commit"
    echo "os=$OS"
    echo "arch=$ARCH"
    echo "go=$(go version)"
    echo "tags=$TAGS"
} >"$ART_DIR/build-info.txt"
[ -s "$ART_DIR/$OUT" ] || { echo "FATAL: 没有产出 GUI 二进制" >&2; exit 1; }
echo "PASS: $OUT"
ls -la "$ART_DIR"
