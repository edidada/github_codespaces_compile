#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/guanzhi/GmSSL.git
cd GmSSL
git checkout v3.1.1
mkdir build
cd build
cmake ..
make
make test
sudo make install
