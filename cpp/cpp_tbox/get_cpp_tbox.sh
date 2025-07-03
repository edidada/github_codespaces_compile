#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt update
sudo apt install build-essential
sudo apt install libgtest-dev libgmock-dev
sudo apt install libmosquitto-dev
sudo apt install libdbus-1-dev
git clone https://gitee.com/cpp-master/cpp-tbox.git
cd cpp-tbox
cmake -B build
cmake --build build
cmake --install build
