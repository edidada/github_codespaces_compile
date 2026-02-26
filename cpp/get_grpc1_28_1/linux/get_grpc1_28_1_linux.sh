#! /bin/bash
sudo apt update
cd "$(dirname "$0")"
uname -a
gcc -v
which gcc
make -v
export MY_INSTALL_DIR=$HOME/.local
mkdir -p $MY_INSTALL_DIR
export PATH="$PATH:$MY_INSTALL_DIR/bin"
cmake --version
yum install -y build-essential autoconf libtool pkg-config
git clone --recurse-submodules https://github.com/grpc/grpc
cd grpc
git checkout v1.28.1
mkdir -p cmake/build
cd cmake/build
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR ../../
make -j
make install
