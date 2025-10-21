#! /bin/bash
sudo apt update
sudo apt install libevent-dev -y
dpkg -L libevent-dev | grep LibeventConfig.cmake
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