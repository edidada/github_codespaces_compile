#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y build-essential libssl-dev wget curl
curl -L -O https://github.com/Kitware/CMake/releases/download/v3.31.0/cmake-3.31.0.tar.gz
tar -zxvf cmake-3.31.0.tar.gz
cd cmake-3.31.0
mkdir build && cd build
../bootstrap --prefix=/usr/local
make -j$(nproc)
sudo make install
cmake --version