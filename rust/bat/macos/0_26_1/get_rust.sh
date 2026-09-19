#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake pkg-config
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v0.26.1 https://github.com/sharkdp/bat.git project
cd project
cargo build --workspace --release
