#! /bin/bash
git clone https://github.com/apache/iceberg-cpp.git
cd iceberg-cpp
git checkout v0.1.0
cmake -S . -B build -G Ninja -DCMAKE_INSTALL_PREFIX=/usr/local -DICEBERG_BUILD_STATIC=ON -DICEBERG_BUILD_SHARED=ON
cmake --build build
cmake --install build
