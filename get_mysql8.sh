#!/bin/bash
# sudo apt install libboost1.65-all-dev -y
# sudo apt install libboost1.67-all-dev -y
git clone -b boost-1.65.0 https://github.com/boostorg/boost.git
cd boost/
git submodule init
git submodule update
./bootstrap.sh --with-libraries=all --prefix=/usr/local/boost
sudo ./b2 install
cd ../
git clone -b mysql-8.0.4 https://github.com/mysql/mysql-server.git
cd mysql-server
mkdir build && cd build
export BOOST_ROOT=/usr/local/boost  
export BOOST_INCLUDEDIR=$BOOST_ROOT/include
cmake .. -DWITH_BOOST=/usr/local/boost -DWITH_SSL=system
make -j5
