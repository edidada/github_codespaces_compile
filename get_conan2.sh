#! /bin/bash
pip3 install conan==2.0.16
conan profile detect
sudo update
sudo apt-get install autoconf automake libtool curl make unzip -y
rm -rf ~/examples2
git clone https://github.com/conan-io/examples2.git
cd examples2/tutorial/consuming_packages/tool_requires
rm -rf build
mkdir build
conan install . --output-folder=build --build=missing
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
./compressor