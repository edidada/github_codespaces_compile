#! /bin/bash
sudo apt update
git clone -b llvmorg-17.0.6 https://github.com/llvm/llvm-project.git
cd llvm-project
mkdir build && cd build
cmake -DLLVM_ENABLE_PROJECTS=clang -DCMAKE_BUILD_TYPE=Release -G "Unix Makefiles" ../llvm
make -j5
cd ../