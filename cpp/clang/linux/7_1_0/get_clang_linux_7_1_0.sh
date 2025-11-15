#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
echo "rustc version"
rustc --version
cargo --version
git clone https://gitcode.com/pollyduan/llvm-project.git
cd llvm-project
git checkout llvmorg-7.1.0
mkdir build && cd build
cmake ../llvm \
  -DCMAKE_BUILD_TYPE=Release \
  -DLLVM_ENABLE_PROJECTS="clang" \
  -DCMAKE_INSTALL_PREFIX=/usr/local/llvm-7.1.0
make -j5