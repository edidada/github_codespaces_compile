#!/bin/bash
sudo apt update
apt-cache showpkg libboost-all-dev
sudo apt install build-essential zlib1g-dev libncurses5-dev libssl-dev libreadline-dev libsqlite3-dev wget llvm libboost-all-dev -y
git clone -b v1.0+5 https://github.com/CrowCpp/Crow.git
cd Crow
mkdir build && cd build
cmake -DCROW_DISABLE_SSL=TRUE -DCROW_DISABLE_AMALGAMATION=TRUE -DCROW_DISABLE_COMPRESSION=TRUE ..
make -j5