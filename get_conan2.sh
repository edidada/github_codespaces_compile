#! /bin/bash
#! /bin/bash
pip3 install conan
sudo update
sudo apt-get install autoconf automake libtool curl make unzip -y
git clone https://github.com/conan-io/examples2.git
cd examples2/tutorial/consuming_packages/tool_requires
rm -rf build
cd build
conan install .. --output-folder=build --build=missing
cmake .. -DCMAKE_TOOLCHAIN_FILE=conan_toolchain.cmake -DCMAKE_BUILD_TYPE=Release
cmake --build .
./compressor
cd examples2/example/conanfile/package_info/components
conan create .