#!/bin/bash
# sudo apt install libboost1.65-all-dev -y
# sudo apt install libboost1.67-all-dev -y
wget https://boostorg.jfrog.io/artifactory/main/release/1.65.0/source/boost_1_65_0.tar.gz
git clone -b mysql-8.0.4 https://github.com/mysql/mysql-server.git
cd mysql-server
rm -rf build
mkdir build && cd build
export BOOST_ROOT=/usr/local/boost
export BOOST_INCLUDEDIR=$BOOST_ROOT/include
cmake .. -DDOWNLOAD_BOOST=1 -DWITH_BOOST=../../boost_1_65_0.tar.gz -DWITH_SSL=system
make -j5
