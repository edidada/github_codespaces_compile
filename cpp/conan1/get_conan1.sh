#! /bin/bash
sudo update
sudo apt-get install autoconf automake libtool curl make unzip -y
pip3 install conan==1.62.0
conan profile update settings.compiler.libcxx=libstdc++11 default
git clone https://github.com/conan-io/examples.git
cd examples/libraries/poco/md5
rm -rf build
mkdir build && cd build
conan install ..
conan build ..
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release
cmake --build .
./bin/md5