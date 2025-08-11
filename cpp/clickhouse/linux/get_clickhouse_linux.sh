#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
echo "rustc version"
rustc --version
cargo --version
git clone https://github.com/ClickHouse/ClickHouse.git
cd ClickHouse
git checkout v24.6.6.6-stable
git submodule update --init
sudo apt install ccache clang lldb nasm yasm doxygen python3-pygments python3-yaml -y
mkdir build
cd build
cmake ../
ninja -j12