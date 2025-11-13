#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
echo "rustc version"
rustc --version
cargo --version
git clone https://github.com/google/benchmark.git
cd benchmark
git checkout v1.9.4
echo "cmake build"
mkdir build && cd build
cmake ../ -DBENCHMARK_ENABLE_GTEST_TESTS=OFF
make
sudo make install
echo "bazel build"
cd ../
wget https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
chmod +x bazelisk-linux-amd64
sudo mv bazelisk-linux-amd64 /usr/local/bin/bazelisk
bazelisk build