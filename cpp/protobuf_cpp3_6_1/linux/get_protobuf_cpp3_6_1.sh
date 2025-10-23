#!/bin/bash
wget -O protobuf-cpp-3.6.1.tar.gz https://github.com/protocolbuffers/protobuf/releases/download/v3.6.1/protobuf-cpp-3.6.1.tar.gz
tar -xzvf protobuf-cpp-3.6.1.tar.gz
cd protobuf-3.6.1/
./configure -prefix=/usr/local
make -j$(nproc)
sudo make install
which protoc
