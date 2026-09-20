#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/systemxlabs/bustubx.git
cd bustubx
RUST_LOG=info,bustubx=debug cargo run --bin bustubx-cli