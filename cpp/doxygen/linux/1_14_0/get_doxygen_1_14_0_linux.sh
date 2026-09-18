#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/doxygen/doxygen.git
cd doxygen
git checkout Release_1_14_0
cmake -B build
cmake --build build