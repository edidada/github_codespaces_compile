#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install libjsoncpp-dev uuid-dev zlib1g-dev openssl libssl-dev libc-ares-dev libbrotli-dev -y
sudo apt install libmariadb-dev-compat libmariadb-dev libsqlite3-dev libhiredis-dev libyaml-cpp-dev libgtest-dev -y
git clone https://github.com/drogonframework/drogon
cd drogon
git checkout v1.9.3
git submodule update --init
mkdir build
cd build
cmake ..
make -j4 && sudo make install
/usr/local/bin/drogon_ctl version