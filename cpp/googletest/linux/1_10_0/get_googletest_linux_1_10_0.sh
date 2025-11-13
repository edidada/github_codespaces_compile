#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/google/googletest.git
cd googletest
git checkout v1.10.x
mkdir build && cd build
cmake ..
make
sudo make install