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
mkdir build && cd build
cmake ../
make
sudo make install