#!/usr/bin/env bash
#
# cc-switch（farion1231/cc-switch，Rust + Tauri 2 桌面应用）完整打包。
# 上游 release.yml：pnpm install --frozen-lockfile + pnpm tauri build --bundles ...
#   - Linux：GTK3 / WebKit2GTK 4.1（libsoup-3.0）系统库，打 deb。
#   - Windows：WebView2（runner 自带），打 msi。
#   - macOS：WKWebView（系统自带），打 dmg / app。
# 上游 tauri.conf.json 的 createUpdaterArtifacts 需要 TAURI_SIGNING_PRIVATE_KEY，
# CI 没有该 secret，先关掉它（不影响 deb/msi/dmg 安装包本身）。
# 多 OS / 多 CPU 矩阵的每条腿各自在本机原生打包。
set -euo pipefail

WORK_DIR="$(pwd)/_cc_switch_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/cc-switch"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

OS="$(uname -s)"
ARCH="$(uname -m)"

echo "==== 0. 宿主环境 ===="
uname -a
node --version
rustc --version
cargo --version

echo "==== 1. 取源码（main 浅克隆，保留 LF）===="
git -c core.autocrlf=false clone --quiet --depth=1 https://github.com/farion1231/cc-switch.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"

echo "==== 2. 关掉 updater 签名产物（CI 无签名密钥）===="
sed -i 's/"createUpdaterArtifacts": true/"createUpdaterArtifacts": false/' src-tauri/tauri.conf.json
grep -n "createUpdaterArtifacts" src-tauri/tauri.conf.json

echo "==== 3. 按 OS 装系统依赖 ===="
case "$OS" in
    Linux)
        sudo apt-get update -qq
        sudo apt-get install -y --no-install-recommends \
            build-essential pkg-config libssl-dev libgtk-3-dev librsvg2-dev \
            libayatana-appindicator3-dev patchelf file wget curl xdg-utils
        sudo apt-get install -y --no-install-recommends libwebkit2gtk-4.1-dev \
            || sudo apt-get install -y --no-install-recommends libwebkit2gtk-4.0-dev
        sudo apt-get install -y --no-install-recommends libsoup-3.0-dev \
            || sudo apt-get install -y --no-install-recommends libsoup2.4-dev
        ;;
esac

echo "==== 4. 安装 pnpm（packageManager: 10.12.3）与前端依赖 ===="
if ! command -v pnpm >/dev/null 2>&1; then
    npm install -g pnpm@10.12.3
fi
pnpm --version
pnpm install --frozen-lockfile

echo "==== 5. Tauri 完整打包 ===="
case "$OS" in
    Linux)                  BUNDLES="deb" ;;
    MINGW* | MSYS* | CYGWIN*) BUNDLES="msi" ;;
    Darwin)                 BUNDLES="dmg,app" ;;
esac
echo "bundles: $BUNDLES"
build_log="$LOG_DIR/tauri-build.log"
if ! pnpm tauri build --bundles "$BUNDLES" >"$build_log" 2>&1; then
    tail -n 120 "$build_log"
    echo "FATAL: cc-switch Tauri 打包失败" >&2
    exit 1
fi
tail -n 15 "$build_log" || true

echo "==== 6. 收集安装包与主二进制 ===="
find "$SRC_DIR/src-tauri/target" -type f \
    \( -name "*.deb" -o -name "*.rpm" -o -name "*.AppImage" -o -name "*.msi" -o -name "*.dmg" \) \
    -print0 | while IFS= read -r -d '' f; do
        cp "$f" "$ART_DIR/"
    done
for f in "$SRC_DIR/src-tauri/target/release/cc-switch" \
         "$SRC_DIR/src-tauri/target/release/cc-switch.exe"; do
    [ -f "$f" ] && cp "$f" "$ART_DIR/" || true
done
{
    echo "project=farion1231/cc-switch"
    echo "commit=$commit"
    echo "os=$OS"
    echo "arch=$ARCH"
    echo "rust=$(rustc --version)"
    echo "bundles=$BUNDLES"
} >"$ART_DIR/build-info.txt"
count="$(find "$ART_DIR" -type f | wc -l)"
[ "$count" -gt 1 ] || { echo "FATAL: 没有产出安装包/二进制" >&2; exit 1; }
echo "PASS: $count 个产物"
ls -la "$ART_DIR"
