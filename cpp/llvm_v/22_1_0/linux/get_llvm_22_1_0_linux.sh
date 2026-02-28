#!/bin/bash
set -e # Exit on error
cd $(dirname "$0")
sudo apt update
sudo apt install lld -y
if [ ! -f llvm-22.src.tar.xz ]; then
  wget -O llvm-22.src.tar.xz https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.0/llvm-project-22.1.0.src.tar.xz
fi

tar -xJvf llvm-22.src.tar.xz
mv llvm-project-22.1.0.src llvm

mkdir build install
cmake llvm -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=$(realpath install) \
  -DLLVM_ENABLE_PROJECTS="clang;lld" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=ON \
  -DLLVM_INCLUDE_TESTS=OFF
cmake --build build --target install
ls -la install