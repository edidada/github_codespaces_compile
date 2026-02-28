#!/bin/bash
set -e # Exit on error
cd $(dirname "$0")
sudo apt update
sudo apt install lld -y
if [ ! -f llvm-22.src.tar.xz ]; then
  wget -O llvm-22.src.tar.xz https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.0/llvm-22.1.0.src.tar.xz
fi
if [ ! -f clang-22.src.tar.xz ]; then
  wget -O clang-22.src.tar.xz https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.0/clang-22.1.0.src.tar.xz
fi
if [ ! -f cmake-22.src.tar.xz ]; then
  wget -O cmake-22.src.tar.xz https://github.com/llvm/llvm-project/releases/download/llvmorg-22.1.0/cmake-22.1.0.src.tar.xz
fi

tar -xJvf llvm-22.src.tar.xz
mv llvm-22*.src llvm
tar -xJvf clang-22.src.tar.xz
mv clang-22*.src clang
tar -xJvf cmake-22.src.tar.xz
mv cmake-22*.src cmake

mkdir build install
cmake llvm -B build -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX=$(realpath install) \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DLLVM_TARGETS_TO_BUILD="X86" \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_LINK_LLVM_DYLIB=ON \
  -DLLVM_USE_LINKER=lld \
  -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=ON \
  -DLLVM_INCLUDE_TESTS=OFF
cmake --build build --target install
