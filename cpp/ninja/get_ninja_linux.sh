#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/ninja-build/ninja.git && cd ninja
git checkout release
./configure.py --bootstrap
./ninja all
cmake -Bbuild-cmake -DBUILD_TESTING=OFF
cmake --build build-cmake
