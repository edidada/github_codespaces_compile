#! /usr/bin/env bash
#
# Tansu（已更名 Nisshi，"née Tansu"；仓库 tansu-io/tansu 仍有效，指向 nisshi-io/nisshi）
# 源码编译：cargo build --release，产出单文件二进制（broker/topic/cat/proxy 全打包）。
#
# 上游：https://github.com/tansu-io/tansu（Cargo.toml -> repository = nisshi-io/nisshi）
# 工作区版本 0.7.0，edition = 2024（需要 Rust 2024 工具链，runner 自带 stable 即可）。
set -euo pipefail

cd "$(dirname "$0")"
git clone --depth=1 https://github.com/tansu-io/tansu.git
cd tansu

echo "---- 工具链 ----"
rustc --version
cargo --version

echo "---- cargo build --release ----"
cargo build --release

echo "---- 产物校验 ----"
ls -lh target/release/ | sed -n '1,40p'
bin=""
for c in target/release/nisshi target/release/tansu; do
    if [ -x "$c" ]; then
        bin="$c"
        break
    fi
done
[ -n "$bin" ] || {
    echo "FATAL: target/release 里没有可执行二进制（预期 nisshi，上游改名前的旧名是 tansu）" >&2
    exit 1
}
"$bin" --help || true
"$bin" --version || true

echo "Tansu/Nisshi 编译完成: $(ls -l "$bin" | awk '{print $5}') bytes -> $bin"
