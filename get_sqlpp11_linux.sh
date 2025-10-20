#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/rbock/sqlpp11.git
cd sqlpp11
#on_duplicate_key_update
git checkout 46cffc8398a3a484db3c28573214407825b34a6d
cmake -S . -B build
cmake --build build