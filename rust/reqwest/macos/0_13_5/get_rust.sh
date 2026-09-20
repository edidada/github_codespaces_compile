#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake pkg-config
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v0.13.5 https://github.com/seanmonstar/reqwest.git project
cd project
cargo build --workspace --release
