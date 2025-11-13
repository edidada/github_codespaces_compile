#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/TinyCC/tinycc.git
cd tinycc
git checkout release_0_9_27
./configure
make
make test
make install