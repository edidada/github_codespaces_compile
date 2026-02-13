#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/open-source-parsers/jsoncpp.git
cd jsoncpp
git checkout 1.9.6
mkdir build && cd build
cmake ..
make
sudo make install