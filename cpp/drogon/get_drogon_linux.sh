#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libjsoncpp-dev uuid-dev zlib1g-dev openssl libssl-dev -y
sudo apt install libmariadbclient-dev libsqlite3-dev libhiredis-dev -y
git clone https://github.com/drogonframework/drogon
cd drogon
git submodule update --init
mkdir build
cd build
cmake ..
make && sudo make install
/usr/local/bin/drogon_ctl version