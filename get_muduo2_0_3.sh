#!/bin/sh
mkdir muduo_2_0_3
cd muduo_2_0_3
git clone https://github.com/chenshuo/muduo.git
sudo update
sudo apt install libboost-all-dev g++ cmake make libboost-dev protobuf-compiler -y
cd muduo
git checkout v2.0.3
chmod +x ./build.sh
./build.sh