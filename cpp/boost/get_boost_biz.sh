#!/bin/bash
wget https://boostorg.jfrog.io/artifactory/main/release/1.65.0/source/boost_1_65_0.tar.bz2
tar -jxvf boost_1_65_0.tar.bz2 -C ./boost
cd boost
./bootstrap.sh --with-libraries=all --prefix=/usr/local/boost
sudo ./b2 install
sudo ldconfig
