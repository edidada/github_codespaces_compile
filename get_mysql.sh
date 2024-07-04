#!/bin/bash
git clone -b 5.7 https://github.com/mysql/mysql-server.git
cd mysql-server
mkdir build && cd build
cmake .. -DWITH_SSL=system
make -j5
