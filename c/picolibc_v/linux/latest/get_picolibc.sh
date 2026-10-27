#! /usr/bin/env bash
#
# picolibc（picolibc/picolibc，newlib 系裸机 C 库，Keith Packard 维护）源码编译：
# 走上游自带构建脚本 scripts/do-arm-configure —— 等价于
#   meson setup --cross-file scripts/cross-arm-none-eabi.txt \
#                -Dincludedir=picolibc/arm-none-eabi/include \
#                -Dlibdir=picolibc/arm-none-eabi/lib ...
# 然后 ninja + meson install，产出 arm-none-eabi（裸机）目标的
# libc.a/libm.a/crt.o + 头文件 + picolibc.specs。
#
# 上游：https://github.com/picolibc/picolibc
# 官方构建说明：README.md / doc（meson 交叉流程，scripts/do-*-configure 即官方 CI 用法）
# 交叉工具链：apt 的 gcc-arm-none-eabi；meson/ninja 用 pip 最新版（上游要求 meson ≥ 0.61）
set -euo pipefail

WORK_DIR="$(pwd)/_picolibc_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/picolibc"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
nproc

echo "==== 1. 工具链就位 ===="
if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends gcc-arm-none-eabi
fi
gcc_version="$(arm-none-eabi-gcc --version | sed -n '1p')"
echo "PASS: $gcc_version"
python3 -m pip install --quiet --user meson ninja
export PATH="$HOME/.local/bin:$PATH"
meson_version="$(meson --version)"
ninja --version
echo "PASS: meson $meson_version"
printf 'gcc=%s\nmeson=%s\n' "$gcc_version" "$meson_version" >"$LOG_DIR/toolchain.txt"

echo "==== 2. 取源码 ===="
# 浅克隆即可（meson 版本号写在 meson.build，不依赖 git tag）
git clone --quiet --depth=1 https://github.com/picolibc/picolibc.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"
printf 'commit=%s\n' "$commit" >"$LOG_DIR/revision.txt"
[ -f scripts/do-arm-configure ] || { echo "FATAL: 上游 scripts/do-arm-configure 不存在" >&2; exit 1; }
[ -f scripts/cross-arm-none-eabi.txt ] || { echo "FATAL: scripts/cross-arm-none-eabi.txt 不存在" >&2; exit 1; }

echo "==== 3. 配置：do-arm-configure（meson 交叉 arm-none-eabi） ----"
mkdir -p "$WORK_DIR/build"
cd "$WORK_DIR/build"
# 上游 CI 同款：do-arm-configure 内部 = do-configure arm-none-eabi -Dtests=true "$@"，
# 本脚本覆盖为 -Dtests=false（测试需要 qemu/semihost 才能跑，这里只编库），
# werror=false 规避 apt gcc 版本抖动，debug=false 用 release 优化。
if ! "$SRC_DIR"/scripts/do-arm-configure \
        -Dtests=false -Dtests-cdefs=false \
        -Dwerror=false -Ddebug=false \
        -Dprefix="$ART_DIR/prefix" \
        >"$LOG_DIR/meson-setup.log" 2>&1; then
    tail -n 60 "$LOG_DIR/meson-setup.log"
    echo "FATAL: picolibc meson 配置失败" >&2
    exit 1
fi
tail -n 3 "$LOG_DIR/meson-setup.log"

echo "==== 4. 编译：ninja ----"
build_log="$LOG_DIR/ninja.log"
if ! ninja >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: picolibc 编译失败（ninja）" >&2
    exit 1
fi
tail -n 3 "$build_log"

echo "==== 5. 安装 + 产物验活 ===="
if ! meson install >"$LOG_DIR/install.log" 2>&1; then
    tail -n 40 "$LOG_DIR/install.log"
    echo "FATAL: meson install 失败" >&2
    exit 1
fi
libc="$(find "$ART_DIR/prefix" -name 'libc.a' | sed -n '1p')"
libm="$(find "$ART_DIR/prefix" -name 'libm.a' | sed -n '1p')"
stdlib_h="$(find "$ART_DIR/prefix" -path '*include*' -name 'stdlib.h' | sed -n '1p')"
specs="$(find "$ART_DIR/prefix" -name '*.specs' | sed -n '1p')"
[ -n "$libc" ] && [ -n "$libm" ] && [ -n "$stdlib_h" ] || {
    echo "---- prefix 内容 ----"
    find "$ART_DIR/prefix" -name '*.a' | head -n 20 || true
    echo "FATAL: 没编出 libc.a/libm.a/stdlib.h" >&2
    exit 1
}
members="$(arm-none-eabi-ar t "$libc" | wc -l)"
printf_sym="$(arm-none-eabi-nm --defined-only "$libc" | grep -c ' T printf$' || true)"
[ "$members" -ge 50 ] || { echo "FATAL: libc.a 成员数异常（$members）" >&2; exit 1; }
[ "$printf_sym" -ge 1 ] || { echo "FATAL: libc.a 里没有 printf 符号" >&2; exit 1; }
echo "PASS: libc.a 成员=$members，含 printf 符号"
[ -n "$specs" ] && echo "PASS: specs 文件：$(basename "$specs")" || echo "WARN: prefix 里没看到 .specs 文件"
ls -l "$libc" "$libm"

echo "==== 6. 归档 ===="
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$LOG_DIR/toolchain.txt" "$ART_DIR/toolchain.txt" 2>/dev/null || true
cp "$build_log" "$ART_DIR/ninja.log" 2>/dev/null || true
cp "$libc" "$ART_DIR/libc.a"
cp "$libm" "$ART_DIR/libm.a"
tar -C "$ART_DIR/prefix" -czf "$ART_DIR/picolibc-arm-none-eabi-prefix.tar.gz" .
( cd "$ART_DIR" && sha256sum -- libc.a libm.a picolibc-arm-none-eabi-prefix.tar.gz >sha256sums.txt )
ls -l "$ART_DIR"
du -sh "$ART_DIR"
echo "PASS: picolibc 裸机库源码编译完成，全部产物在 $ART_DIR"
