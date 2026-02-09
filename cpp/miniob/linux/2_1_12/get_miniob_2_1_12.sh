#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/libevent/libevent.git
cd libevent
git checkout release-2.1.12-stable
mkdir build && cd build
cmake ..
make
sudo make install
cd ..
git clone https://github.com/oceanbase/miniob.git
cd miniob
sudo bash build.sh init
sudo bash build.sh release