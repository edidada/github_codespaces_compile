#!/bin/bash
wget -O protobuf-cpp-3.19.4.tar.gz https://github.com/protocolbuffers/protobuf/releases/download/v3.19.4/protobuf-cpp-3.19.4.tar.gz
tar -xzvf protobuf-cpp-3.19.4.tar.gz
cd protobuf-3.19.4/
./configure -prefix=/usr/local
make -j5
sudo make install
which protoc
