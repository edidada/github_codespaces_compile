#!/bin/bash
git clone -b boost-1.65.0 https://github.com/boostorg/boost.git
cd boost/
git submodule init
git submodule update
./bootstrap.sh --with-libraries=all --prefix=/usr/local/boost
sudo ./b2 install
sudo ldconfig
