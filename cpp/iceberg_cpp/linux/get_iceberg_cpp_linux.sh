#! /bin/bash
sudo apt update
git clone https://github.com/apache/iceberg-cpp.git
cd iceberg-cpp
git checkout v0.1.0
sudo mkdir /usr/local/iceberg-cpp/bin
sudo mkdir /usr/local/iceberg-cpp/include
sudo mkdir /usr/local/iceberg-cpp/lib
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local/iceberg-cpp -DICEBERG_BUILD_STATIC=ON -DICEBERG_BUILD_SHARED=ON
cmake --build build
cmake --install build
