#!/bin/bash
wget http://dl.bintray.com/boostorg/release/1.65.0/source/boost_1_65_0.tar.gz
git clone -b 5.7 https://github.com/mysql/mysql-server.git
cd mysql-server
mkdir build && cd build
cmake ..  -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../../boost_1_65_0.tar.gz -DWITH_SSL=system
make -j5
