#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake pkg-config
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v1.12.0 https://github.com/rayon-rs/rayon.git project
cd project
cargo build --workspace --release
