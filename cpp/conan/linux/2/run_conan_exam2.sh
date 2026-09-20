#! /bin/bash
rm -rf ~/examples2
git clone https://github.com/conan-io/examples2.git
cd examples2/tutorial/consuming_packages/tool_requires
rm -rf build
mkdir build
conan install . --output-folder=build --build=missing
cd build
source conanbuild.sh
source deactivate_conanbuild.sh