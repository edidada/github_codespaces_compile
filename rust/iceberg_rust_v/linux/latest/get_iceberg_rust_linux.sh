#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/apache/iceberg-rust.git
cd iceberg-rust
git checkout v0.6.0
cargo build
