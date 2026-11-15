#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone -b release/2.5 https://github.com/microsoft/msquic.git
cd msquic
git submodule update --init --recursive
cmake -B build .
cmake --build build
sudo cmake --install build
