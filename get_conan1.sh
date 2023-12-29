#! /bin/bash
#! /bin/bash
pip3 install conan==1.62.0
conan profile update settings.compiler.libcxx=libstdc++11 default
sudo update
sudo apt-get install autoconf automake libtool curl make unzip -y
git clone https://github.com/conan-io/examples.git
cd examples/tutorial/consuming_packages/tool_requires
rm -rf build
mkdir build
conan install . --output-folder=build --build=missing
cd build
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
./compressor