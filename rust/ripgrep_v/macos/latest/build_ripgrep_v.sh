#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 https://github.com/BurntSushi/ripgrep.git project
cd project
cargo build --release
