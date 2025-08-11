#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
echo "ubuntu version"
lsb_release -a
hostnamectl
git clone https://github.com/ClickHouse/ClickHouse.git
cd ClickHouse
git checkout v24.6.6.6-stable
git submodule update --init
sudo apt install ccache clang lldb -y
mkdir build
cd build
cmake ../