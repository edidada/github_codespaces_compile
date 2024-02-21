#!/bin/bash
git clone -b mysql-8.0.4 https://github.com/mysql/mysql-server.git
cd mysql-server
mkdir build && cd build
cmake .. -DWITH_SSL=system
make -j5
