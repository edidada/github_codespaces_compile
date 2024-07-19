#!/bin/bash
sudo apt update
apt-cache showpkg libboost-all-dev
sudo apt install libboost-all-dev=1.64.0
sudo apt install build-essential zlib1g-dev libncurses5-dev libssl-dev libreadline-dev libsqlite3-dev wget llvm -y
git clone -b v1.0+5 https://github.com/CrowCpp/Crow.git
cd Crow
mkdir build && cd build
cmake ..
make -j5