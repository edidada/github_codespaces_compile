#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libboost-dev -y
git clone https://github.com/qicosmos/rest_rpc.git
cd rest_rpc
cd examples
mkdir build
cd build
cmake ..
make