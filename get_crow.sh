#!/bin/bash
git clone -b v1.0+5 https://github.com/CrowCpp/Crow.git
cd Crow
mkdir build && cd build
cmake ..
make -j5