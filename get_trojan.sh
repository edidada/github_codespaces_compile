#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install trojan -y
sudo apt-get install libboost-all-dev -y
git clone https://github.com/trojan-gfw/trojan.git
cd trojan/
mkdir build
cd build/
cmake ..
make
ctest
sudo make install
