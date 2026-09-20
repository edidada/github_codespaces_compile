#!/bin/bash
cd "$(dirname "$0")"
git clone -b v0.2.1 https://github.com/Svetlitski/fcp.git
cd fcp
cargo build --release
cargo test
