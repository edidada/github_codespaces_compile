#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libtinyxml-dev libprotobuf-dev -y
#wget -O v1.2.0.tar.gz https://github.com/Gooddbird/tinyrpc/archive/refs/tags/v1.2.0.tar.gz
git clone https://github.com/Gooddbird/tinyrpc
cd tinyrpc
git checkout v1.2.0
cd testcases
protoc --cpp_out=./ test_tinypb_server.proto
cd ..
mkdir bin && mkdir lib && mkdir build
sudo ./build.sh