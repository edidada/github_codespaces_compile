#!/bin/bash
cd "$(dirname "$0")"
echo "git clone boost"
git clone -b boost-1.66.0 https://github.com/boostorg/boost.git
cd boost*/
echo "git submodule"
git submodule init
git submodule update
echo "run bootstrap script"
./bootstrap.sh --with-libraries=all
sudo ./b2 install
./b2 --show-libraries
sudo ldconfig
cd ..
