#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/tboox/tbox.git
cd tbox
git checkout v1.7.7
./configure
make -j4
sudo make install
find /usr/local/include/ -name "tbox.h"