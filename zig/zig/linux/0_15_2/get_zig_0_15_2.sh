#! /bin/bash
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-20 main"
sudo apt-get update
sudo apt install -y llvm-20-dev clang-20 libclang-20-dev liblld-20-dev
cd "$(dirname "$0")"
git clone https://codeberg.org/ziglang/zig.git
cd zig
git checkout 0.15.2
mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=Release -DZIG_PREFER_CLANG_CPP_DYLIB=ON
make