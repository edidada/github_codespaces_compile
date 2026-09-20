#! /bin/bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y build-essential autoconf libtool pkg-config cmake
cd "$(dirname "$0")"
uname -a
gcc -v
which gcc
make -v
export MY_INSTALL_DIR=$HOME/.local
mkdir -p $MY_INSTALL_DIR
export PATH="$PATH:$MY_INSTALL_DIR/bin"
cmake --version
# The historical 1.28 checkout no longer builds reliably on hosted runners.
# Build a maintained gRPC release instead.
git clone --branch v1.75.1 --recurse-submodules --shallow-submodules --depth 1 https://github.com/grpc/grpc
cd grpc
git submodule sync --recursive
git submodule update --init --recursive
mkdir -p cmake/build
cd cmake/build
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_CXX_STANDARD=17 -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR ../../
make -j
make install
