#! /bin/bash
sudo apt update
cd "$(dirname "$0")"
sudo apt install -y curl
git clone https://github.com/HowardHinnant/date.git
cd date
git checkout v3.0.1
mkdir build
cd build
cmake -DENABLE_DATE_TESTING=ON -DBUILD_TZ_LIB=ON ../
cmake --build .
cmake --install .
