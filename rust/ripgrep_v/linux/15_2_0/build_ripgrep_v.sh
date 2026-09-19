#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch 15.2.0 https://github.com/BurntSushi/ripgrep.git project
cd project
cargo build --release
