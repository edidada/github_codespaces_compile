#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get -y update
sudo apt-get install -y openssl libssl-dev git g++ make cmake libmysqlclient-dev libpq-dev
git clone https://github.com/pocoproject/poco.git
cd poco
git checkout poco-1.12.3-release
cmake -S . -B build
cmake --build build
#sudo cmake --install build
sudo cmake --build . --target install