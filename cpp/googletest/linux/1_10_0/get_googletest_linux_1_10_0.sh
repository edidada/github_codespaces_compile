#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/google/googletest.git
cd googletest
git checkout v1.10.x
mkdir build && cd build
cmake .. \
    -DGTEST_HAS_PTHREAD=0 \
    -DCMAKE_CXX_FLAGS="-Wno-error=maybe-uninitialized"
make
sudo make install