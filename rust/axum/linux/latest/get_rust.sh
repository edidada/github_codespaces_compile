#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update && sudo apt-get install -y git build-essential pkg-config libssl-dev cmake perl
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1  https://github.com/tokio-rs/axum.git project
cd project
cargo build --workspace --release
