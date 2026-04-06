#! /bin/bash
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | sudo apt-key add -
sudo add-apt-repository "deb http://apt.llvm.org/jammy/ llvm-toolchain-jammy-20 main"
sudo apt-get update
sudo apt install -y llvm-20-dev clang-20 libclang-20-dev liblld-20-dev
cd "$(dirname "$0")"
wget https://github.com/llvm/llvm-project/releases/download/llvmorg-20.1.3/llvm-20.1.3-x86_64-linux-gnu-ubuntu-22.04.tar.xz
tar xf llvm-20.1.3-x86_64-linux-gnu-ubuntu-22.04.tar.xz
sudo mkdir -p /opt/llvm-20-fulldev
sudo cp -r llvm-20.1.3-x86_64-linux-gnu-ubuntu-22.04/* /opt/llvm-20-fulldev/
git clone https://codeberg.org/ziglang/zig.git
cd zig
git checkout 0.15.2
mkdir build && cd build
cmake ../
      -DCMAKE_BUILD_TYPE=Release \
      -DZIG_PREFER_CLANG_CPP_DYLIB=ON \
      -DCMAKE_PREFIX_PATH=/opt/llvm-20-fulldev \
make