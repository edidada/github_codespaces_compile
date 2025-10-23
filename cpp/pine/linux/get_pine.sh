#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/yuesong-feng/pine.git
cd pine
mkdir build && cd build
cmake .. # for debug, add -DCMAKE_BUILD_TYPE=DEBUG
make format      # optional
make cpplint      # optional
make clang-tidy  # optional
make
