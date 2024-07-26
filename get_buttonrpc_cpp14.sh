#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libzmq3-dev
dpkg -s libzmq3-dev | grep Version
git clone https://github.com/edidada/buttonrpc_cpp14.git
cd buttonrpc_cpp14
sudo cp *.hpp /usr/local/include
sudo ldconfig
cd example
mkdir build && cd build
cmake ../
make -j4