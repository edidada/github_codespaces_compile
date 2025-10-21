#!/bin/bash
git clone https://github.com/google/protobuf.git
cd protobuf
git checkout v3.11.0
git submodule update --init --recursive
chmod +x ./autogen.sh
./autogen.sh
chmod +x ./configure
./configure
make -j5
