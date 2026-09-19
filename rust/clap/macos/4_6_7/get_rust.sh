#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake pkg-config
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v4.6.7 https://github.com/clap-rs/clap.git project
cd project
cargo build --workspace --release
