#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/antlr/antlr4.git
cd antlr4
git checkout 4.13.2
cd tool
mvn clean package
ls target -la
cd ../
cd runtime/Cpp
mkdir build && cd build
cmake -DANTLR_BUILD_CPP_TESTS=OFF ..
make
cpack
ls