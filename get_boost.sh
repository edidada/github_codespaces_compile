#!/bin/bash
git clone https://github.com/boostorg/boost.git
cd boost/
git checkout boost-1.65.0
git submodule init
git submodule update
./bootstrap.sh --with-libraries=all
sudo ./b2 install
sudo ldconfig