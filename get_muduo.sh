#!/bin/sh
mkdir muduo_master
cd muduo_master
git clone https://github.com/chenshuo/muduo.git
sudo update
sudo apt install libboost-all-dev protobuf-compiler -y
export Boost_INCLUDE_DIR=/usr/include
cd muduo
chmod +x ./build.sh
./build.sh