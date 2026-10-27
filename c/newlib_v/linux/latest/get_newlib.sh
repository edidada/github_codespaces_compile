#! /usr/bin/env bash
#
# Newlib（sourceware，裸机 C 库）源码编译：
# 官方发布 tarball（自带生成的 configure），按 newlib README 给的
# cross-build 流程用 arm-none-eabi 交叉工具链编出裸机 libc/libm：
#
#   ../configure --target=arm-none-eabi --prefix=... --disable-multilib
#   make -jN && make install
#
# 上游：https://sourceware.org/newlib（git 化仓库 sourceware.org/git/newlib-cygwin）
# 官方构建说明：newlib README / docs（target 版交叉编译）
# 发布页：https://sourceware.org/pub/newlib/（最新发布 4.6.0.20260123，2026-01-23）
#
# 交叉工具链用 apt 的 gcc-arm-none-eabi（含 binutils-arm-none-eabi），
# 编译产物是真正的裸机（system=none）目标库，跑在 x86_64 runner 上。
set -euo pipefail

WORK_DIR="$(pwd)/_newlib_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
nproc

echo "==== 1. 交叉工具链就位 ===="
if ! command -v arm-none-eabi-gcc >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y --no-install-recommends gcc-arm-none-eabi
fi
gcc_version="$(arm-none-eabi-gcc --version | sed -n '1p')"
as_version="$(arm-none-eabi-as --version | sed -n '1p')"
echo "PASS: $gcc_version"
echo "PASS: $as_version"
printf 'gcc=%s\nas=%s\n' "$gcc_version" "$as_version" >"$LOG_DIR/toolchain.txt"

echo "==== 2. 取源码 ===="
NEWLIB_VER="4.6.0.20260123"
URL="https://sourceware.org/pub/newlib/newlib-${NEWLIB_VER}.tar.gz"
if ! curl -fL --max-time 300 "$URL" -o "$WORK_DIR/newlib.tar.gz"; then
    echo "FATAL: 官方 tarball 下载失败：$URL" >&2
    exit 1
fi
tar -zxf "$WORK_DIR/newlib.tar.gz" -C "$WORK_DIR"
SRC_DIR="$WORK_DIR/newlib-${NEWLIB_VER}"
cd "$SRC_DIR"
printf 'release=%s\n' "$NEWLIB_VER" >"$LOG_DIR/revision.txt"
echo "PASS: 源码就位 newlib-$NEWLIB_VER（官方发布 tarball，含生成的 configure）"
[ -f configure ] || { echo "FATAL: tarball 里没有 configure" >&2; exit 1; }

echo "==== 3. 配置：configure --target=arm-none-eabi ----"
PREFIX_DIR="$WORK_DIR/prefix"
mkdir -p "$WORK_DIR/build"
cd "$WORK_DIR/build"
if ! ../newlib-${NEWLIB_VER}/configure \
        --target=arm-none-eabi \
        --prefix="$PREFIX_DIR" \
        --disable-multilib \
        >"$LOG_DIR/configure.log" 2>&1; then
    tail -n 40 "$LOG_DIR/configure.log"
    echo "FATAL: newlib configure 失败" >&2
    exit 1
fi
tail -n 5 "$LOG_DIR/configure.log"

echo "==== 4. 编译：make ----"
build_log="$LOG_DIR/make.log"
if ! make -j"$(nproc)" >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: newlib 编译失败（make）" >&2
    exit 1
fi
grep -E '^(make|gcc)' "$build_log" | tail -n 2 || true

if ! make install >>"$build_log" 2>&1; then
    tail -n 40 "$build_log"
    echo "FATAL: newlib make install 失败" >&2
    exit 1
fi

echo "==== 5. 产物验活 ===="
libc="$(find "$PREFIX_DIR" -name 'libc.a' | sed -n '1p')"
libm="$(find "$PREFIX_DIR" -name 'libm.a' | sed -n '1p')"
[ -n "$libc" ] && [ -n "$libm" ] || {
    echo "---- prefix 内容 ----"
    find "$PREFIX_DIR" -name '*.a' | head -n 20 || true
    echo "FATAL: 没编出 libc.a/libm.a" >&2
    exit 1
}
members="$(arm-none-eabi-ar t "$libc" | wc -l)"
printf_sym="$(arm-none-eabi-nm --defined-only "$libc" | grep -c ' T printf$' || true)"
[ "$members" -ge 50 ] || { echo "FATAL: libc.a 成员数异常（$members）" >&2; exit 1; }
[ "$printf_sym" -ge 1 ] || { echo "FATAL: libc.a 里没有 printf 符号" >&2; exit 1; }
echo "PASS: libc.a 成员=$members，含 printf 符号"
ls_l="$(ls -l "$libc" "$libm")"
echo "$ls_l"

echo "==== 6. 归档 ===="
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$LOG_DIR/toolchain.txt" "$ART_DIR/toolchain.txt" 2>/dev/null || true
cp "$build_log" "$ART_DIR/make.log" 2>/dev/null || true
cp "$libc" "$ART_DIR/libc.a"
cp "$libm" "$ART_DIR/libm.a"
tar -C "$PREFIX_DIR" -czf "$ART_DIR/newlib-arm-none-eabi-prefix.tar.gz" .
( cd "$ART_DIR" && sha256sum -- libc.a libm.a newlib-arm-none-eabi-prefix.tar.gz >sha256sums.txt )
ls -l "$ART_DIR"
du -sh "$ART_DIR"
echo "PASS: newlib 裸机库源码编译完成，全部产物在 $ART_DIR"
