#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/rbatis/rbatis.git
cd rbatis
git checkout v4.5.33
cargo build --verbose
