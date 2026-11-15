#! /bin/bash
sudo apt update
sudo apt install -y ninja-build
git clone -b llvmorg-23.1.5 https://github.com/llvm/llvm-project.git
cd llvm-project
mkdir build && cd build
cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Ninja" ../llvm
ninja
#cd ../
#cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
#make -j5
#cd ../