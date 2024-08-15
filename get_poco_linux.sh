#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get -y update
sudo apt-get install -y openssl libssl-dev git g++ make cmake libmysqlclient-dev libpq-dev
git clone https://github.com/pocoproject/poco.git
cd poco
git checkout poco-1.12.3-release
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -G "Unix Makefiles" -S . -B build
ls -la build
cmake --build build
ls -la build
#sudo cmake --install build
sudo cmake --build . --target install