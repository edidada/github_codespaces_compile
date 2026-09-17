#!/bin/bash
cd "$(dirname "$0")"
git clone -b v0.2.1 https://github.com/Svetlitski/fcp.git
cd fcp
sed -i 's/err));/err))/' src/filesystem.rs
sed -i 's/env::args().skip(1).collect()/Box::new(env::args().skip(1).collect::<Vec<_>>())/' src/main.rs
cargo build --release
cargo test
