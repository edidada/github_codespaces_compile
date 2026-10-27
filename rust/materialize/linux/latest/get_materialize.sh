#! /usr/bin/env bash
#
# Materialize（MaterializeInc/materialize，Rust 流式数据库）源码编译：
# 官方开发构建就是标准 cargo：cargo build --release（workspace default-members
# 以 src/environmentd 导出主二进制 environmentd，并连带编出 clusterd）。
#
# 上游：https://github.com/MaterializeInc/materialize（默认分支 main）
# 官方构建说明：README/CONTRIBUTING（建议 cargo），无 rust-toolchain 钉版，
# runner 自带 stable rust 即可。
#
# 注：root Cargo.toml 的 [profile.release] 为 lto="thin" + debug=2（全量调试
# 信息），包体积/磁盘占用过大；此处用 cargo 官方 env 覆盖
# CARGO_PROFILE_RELEASE_DEBUG=0（编译语义不变，仅去掉 core dump 调试信息）。
set -euo pipefail

WORK_DIR="$(pwd)/_materialize_build"
LOG_DIR="$WORK_DIR/logs"
ART_DIR="$WORK_DIR/artifacts"
SRC_DIR="$WORK_DIR/materialize"
rm -rf "$WORK_DIR"
mkdir -p "$LOG_DIR" "$ART_DIR"

echo "==== 0. 宿主环境 ===="
uname -a
sed -n 's/^PRETTY_NAME=//p' /etc/os-release | sed -n '1p' | tr -d '"'
rustc --version
cargo --version
nproc
df -h / | sed -n '1,2p'

echo "==== 1. 取源码 ===="
# 完整克隆（非 shallow）：mz-build-info 会用 git describe 嵌入版本号
git clone --quiet https://github.com/MaterializeInc/materialize.git "$SRC_DIR"
cd "$SRC_DIR"
commit="$(git rev-parse --short HEAD)"
echo "PASS: 源码就位 commit=$commit"
printf 'commit=%s\n' "$commit" >"$LOG_DIR/revision.txt"

echo "==== 2. 编译：cargo build --release -p mz-environmentd ----"
export CARGO_PROFILE_RELEASE_DEBUG=0
build_log="$LOG_DIR/cargo-build.log"
if ! cargo build --release -p mz-environmentd >"$build_log" 2>&1; then
    tail -n 80 "$build_log"
    echo "FATAL: Materialize 编译失败（cargo build --release）" >&2
    exit 1
fi
grep -E 'Built target' "$build_log" | tail -n 3 || true
df -h / | sed -n '2p'

echo "==== 3. 产物验活 ===="
list="$(find target/release -maxdepth 1 -type f -perm -u+x \( -name 'environmentd' -o -name 'clusterd' -o -name 'balancerd' \) | sort)"
[ -n "$list" ] || {
    echo "---- target/release 目录 ----"
    ls -l target/release 2>/dev/null | head -n 20 || true
    echo "FATAL: 没编译出 environmentd/clusterd 可执行文件" >&2
    exit 1
}
printf '%s\n' "$list" | tee "$WORK_DIR/bins.txt"
pass_envd=0
while IFS= read -r bin; do
    case "$bin" in */environmentd) pass_envd=1;; esac
    name="$(basename "$bin")"
    if "$bin" --version >"$LOG_DIR/$name-version.log" 2>&1; then
        echo "PASS: $name --version => $(head -n 1 "$LOG_DIR/$name-version.log")"
    else
        echo "WARN: $name --version 没有直接跑通：$(tail -n 3 "$LOG_DIR/$name-version.log")"
    fi
done <"$WORK_DIR/bins.txt"
[ "$pass_envd" = 1 ] || { echo "FATAL: 没有编译出服务端 environmentd" >&2; exit 1; }
grep -E 'Built target' "$build_log" | tail -n 3 || true
echo "PASS: environmentd 已出，二进制逐个 --version 校验"

echo "==== 4. 归档 ===="
cp "$WORK_DIR/bins.txt" "$ART_DIR/bin-list.txt"
cp "$LOG_DIR/revision.txt" "$ART_DIR/revision.txt"
cp "$build_log" "$ART_DIR/cargo-build.log" 2>/dev/null || true
while IFS= read -r bin; do
    cp "$bin" "$ART_DIR/"
done <"$WORK_DIR/bins.txt"
( cd "$ART_DIR" && sha256sum -- ./*.txt ./environmentd ./clusterd >sha256sums.txt ) 2>/dev/null || true
ls -l "$ART_DIR"
du -sh "$ART_DIR"
echo "PASS: Materialize 源码编译完成，全部产物在 $ART_DIR"
