#! /bin/bash
cd "$(dirname "$0")"
sudo make update
sudo apt install flex libfl-dev -y
# 1. 下载源码（以2.1.12稳定版为例）
wget https://www.tcpdump.org/release/libpcap-1.10.5.tar.xz
# 2. 解压
tar -xf libpcap-1.10.5.tar.xz
cd libpcap-1.10.5
./configure
make -j$(nproc)
sudo make install