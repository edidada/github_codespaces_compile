#! /bin/bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y autoconf automake libtool curl make unzip
pip3 install conan==1.62.0
conan profile update settings.compiler.libcxx=libstdc++11 default
git clone https://github.com/conan-io/examples.git
cd examples/libraries/poco/md5
rm -rf build
mkdir build && cd build
conan install .. -s build_type=Release
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build .
./bin/md5
