#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libboost-dev -y
git clone https://github.com/qicosmos/rest_rpc.git
cd rest_rpc
export C_INCLUDE_PATH=$C_INCLUDE_PATH:/home/runner/work/github_codespaces_compile/github_codespaces_compile/rest_rpc/include
sudo cp -r include/* /usr/local/include
sudo ldconfig
git checkout v0.12
cd examples
mkdir build
cd build
cmake ..
make