#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/tikv/tikv.git
cd tikv
make build
cargo check --all