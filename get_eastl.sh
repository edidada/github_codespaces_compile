#!/bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/electronicarts/EASTL.git
cd EASTL
git checkout 3.21.12
git submodule update --init --recursive
mkdir your_build_folder && cd your_build_folder
cmake ../ -DEASTL_BUILD_TESTS:BOOL=OFF
cmake --build .