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
git clone --branch v1.28.1 --recurse-submodules --shallow-submodules --depth 1 https://github.com/grpc/grpc
cd grpc
git submodule sync --recursive
git submodule update --init --recursive
# gRPC 1.28 pins an Abseil revision that relied on an indirect <limits>
# include.  GCC 13 no longer provides it indirectly.
sed -i '/#include <algorithm>/a #include <limits>' third_party/abseil-cpp/absl/synchronization/internal/graphcycles.cc
sed -i 's/std::max(SIGSTKSZ, 65536)/std::max<long>(SIGSTKSZ, 65536)/' third_party/abseil-cpp/absl/debugging/failure_signal_handler.cc
mkdir -p cmake/build
cd cmake/build
cmake -DgRPC_INSTALL=ON -DgRPC_BUILD_TESTS=OFF -DCMAKE_CXX_STANDARD=14 -DCMAKE_INSTALL_PREFIX=$MY_INSTALL_DIR ../../
make -j
make install
