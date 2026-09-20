#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake pkg-config
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v10.5.0 https://github.com/sharkdp/fd.git project
cd project
cargo build --workspace --release
