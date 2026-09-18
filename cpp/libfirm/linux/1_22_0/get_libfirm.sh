#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/libfirm/libfirm.git
cd libfirm
make -j$(nproc)
sudo make install