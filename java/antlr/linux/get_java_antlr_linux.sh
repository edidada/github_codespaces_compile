#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/antlr/antlr4.git
cd antlr4
git checkout 4.13.2
cd tool
mvn clean package
ls target -la
cd ../
mvn package
ls runtime/Java/target -la
cd runtime/Cpp
sudo apt install -y libutfcpp-dev uuid-dev
mkdir build && cd build
cmake -DANTLR_BUILD_CPP_TESTS=OFF ..
make
cpack
ls
cd "$(dirname "$0")"
wget -O antlr.jar https://www.antlr.org/download/antlr-4.13.2-complete.jar
wget -O cpp-runtime.zip https://www.antlr.org/download/antlr4-cpp-runtime-4.13.2-source.zip
unzip cpp-runtime.zip -d source
mkdir build install
cmake source -B build -G Ninja \
  -DCMAKE_INSTALL_PREFIX=$(realpath install) \
  -DANTLR4_INSTALL=ON
cmake --build build --target install
