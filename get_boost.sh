#!/bin/bash
#git clone https://github.com/boostorg/boost.git
wget https://boostorg.jfrog.io/artifactory/main/release/1.65.0/source/boost_1_65_0.tar.gz
#cd boost/
tar -zxvf boost_1_65_0.tar.gz
cd boost_*/
#git checkout boost-1.65.0
git submodule init
git submodule update
./bootstrap.sh --with-libraries=all
sudo ./b2 install
./b2 --show-libraries
sudo ldconfig