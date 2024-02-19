#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get install trojan
sudo apt-get update
git clone https://github.com/trojan-gfw/trojan.git
cd trojan/
mkdir build
cd build/
cmake ..
make
ctest
sudo make install
