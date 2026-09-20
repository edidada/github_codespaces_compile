#!/bin/bash
set -euo pipefail
wget -O boost_1_77_0.tar.gz https://archives.boost.io/release/1.77.0/source/boost_1_77_0.tar.gz
git clone -b mysql-8.0.42 --depth 1 https://github.com/mysql/mysql-server.git
cd mysql-server
rm -rf build
mkdir build && cd build
export BOOST_ROOT=/usr/local/boost
export BOOST_INCLUDEDIR=$BOOST_ROOT/include
cmake .. -DWITH_BOOST=../../boost_1_77_0.tar.gz -DWITH_SSL=system
make -j5
