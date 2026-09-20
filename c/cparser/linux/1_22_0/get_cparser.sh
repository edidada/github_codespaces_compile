#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone --recursive https://github.com/libfirm/cparser.git
cd cparser
make -j$(nproc)
ls -la ./build/debug/cparser