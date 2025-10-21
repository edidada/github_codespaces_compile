#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone -b v1.11.1 https://github.com/ninja-build/ninja.git
cd ninja
cmake -Bbuild-cmake
cmake --build build-cmake
./build-cmake/ninja --version