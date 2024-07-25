#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
wget -O protobuf-cpp-3.19.4.tar.gz https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-cpp-3.19.4.tar.gz
tar -xzvf protobuf-cpp-3.19.4.tar.gz
cd protobuf-3.19.4/
./configure -prefix=/usr/local
make -j5
sudo make install
which protoc
cd ../
sudo cp /usr/local/lib/libprotobuf.a /usr/lib
sudo ldconfig
sudo apt install libtinyxml-dev -y
# copy 头文件到系统头文件搜索路径下
sudo mkdir /usr/include/tinyxml
sudo cp /usr/include/tinyxml.h /usr/include/tinyxml/
#wget -O v1.2.0.tar.gz https://github.com/Gooddbird/tinyrpc/archive/refs/tags/v1.2.0.tar.gz
git clone https://github.com/Gooddbird/tinyrpc
cd tinyrpc
# git checkout v1.2.0
git checkout 3db2785f7c46d64b70999894154aa4096f1a13ef
cd testcases
protoc --cpp_out=./ test_tinypb_server.proto
cd ..
mkdir bin && mkdir lib && mkdir build
sudo ./build.sh