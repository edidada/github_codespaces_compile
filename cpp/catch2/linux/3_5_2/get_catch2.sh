#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/catchorg/Catch2.git
cd Catch2
git checkout v3.5.2
mkdir build && cd build
cmake ../
make -j10
sudo make install