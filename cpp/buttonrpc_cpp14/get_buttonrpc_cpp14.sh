#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libzmq3-dev -y
dpkg -L libzmq3-dev
dpkg -s libzmq3-dev | grep Version
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/x86_64-linux-gnu
git clone https://github.com/edidada/buttonrpc_cpp14.git
cd buttonrpc_cpp14
sudo cp *.hpp /usr/local/include
sudo ldconfig
cd example
mkdir build && cd build
cmake ../
make -j4