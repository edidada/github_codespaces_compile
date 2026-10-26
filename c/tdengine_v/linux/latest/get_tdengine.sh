#! /usr/bin/env bash
#
# TDengine 时序数据库（taosdata/TDengine，C）源码编译：
# 走官方 README 给的本地构建路径：clone -> 新建并进入构建目录 -> cmake .. -> cmake --build .
# 产物是构建目录 bin/ 下的 taosd（服务端）与 taos（CLI），再视配置加 taosBenchmark。
#
# 上游：https://github.com/taosdata/TDengine
# 官方构建说明：README/docs（Ubuntu：mkdir debug; cd debug; cmake ..; cmake --build .）
# runner 自带 cmake/gcc，命令行依赖 cmake 处理；不额外装包。
set -euo pipefail

WORK_DIR="$(pwd)/_tdengine_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/TDengine"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
gcc --version | sed -n '1p'
cmake --version | sed -n '1p'

echo "==== 1. 取源码 ===="
git clone --quiet --depth=1 https://github.com/taosdata/TDengine.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"
printf 'commit=%s\n' "$commit" >"$LOG_DIR/revision.txt"

echo "==== 2. cmake 配置 ===="
mkdir -p build
cd "$WORK_DIR/build"
if ! cmake "$SRC_DIR" -DCMAKE_BUILD_TYPE=Release -DBUILD_TOOLS=true >"$LOG_DIR/cmake.log" 2>&1; then
    echo "WARN: 带 -DBUILD_TOOLS=true 配置失败，按 README 的默认参数再配一次"
    tail -n 20 "$LOG_DIR/cmake.log" || true
    cmake "$SRC_DIR" -DCMAKE_BUILD_TYPE=Release >>"$LOG_DIR/cmake.log" 2>&1
fi
tail -n 3 "$LOG_DIR/cmake.log"

echo "==== 3. 编译：cmake --build ----"
build_log="$LOG_DIR/build.log"
if ! cmake --build . -j"$(nproc)" >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: TDengine 编译失败（cmake --build）" >&2
    exit 1
fi
grep -E 'Built target taosd' "$build_log" | tail -n 2 || true

echo "==== 4. 产物验活 ===="
list="$(find . -maxdepth 3 -type f \( -name 'taosd' -o -name 'taos' -o -name 'taosBenchmark' \) | sort)"
[ -n "$list" ] || {
    echo "---- 构建目录树 ----"
    find . -maxdepth 3 -type d | sort | head -n 20
    echo "FATAL: 没编译出 taosd/taos 可执行文件" >&2
    exit 1
}
printf '%s\n' "$list" | tee "$WORK_DIR/bins.txt"
pass1=0
while IFS= read -r bin; do
    case "$bin" in */taosd) pass1=1;; esac
    name="$(basename "$bin")"
    if "$bin" -V >"$LOG_DIR/$name-V.log" 2>&1; then
        echo "PASS: $name -V => $(head -n 1 "$LOG_DIR/$name-V.log")"
    else
        echo "WARN: $name -V 没有直接跑通：$(tail -n 3 "$LOG_DIR/$name-V.log")"
    fi
done <"$WORK_DIR/bins.txt"
[ "$pass1" = 1 ] || { echo "FATAL: 没有编译出服务端 taosd" >&2; exit 1; }
echo "PASS: taosd 已出，逐个 -V 校验"

echo "==== 5. 归档 ===="
cp "$WORK_DIR/bins.txt" "$ART_DIR/bin-list.txt"
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$build_log" "$ART_DIR/build.log" 2>/dev/null || true
while IFS= read -r bin; do
    cp "$bin" "$ART_DIR/"
done <"$WORK_DIR/bins.txt"
( cd "$ART_DIR" && sha256sum -- taosd taos >sha256sums.txt ) 2>/dev/null || true
ls -l "$ART_DIR"
echo "PASS: TDengine 源码编译完成，全部产物在 $ART_DIR"
