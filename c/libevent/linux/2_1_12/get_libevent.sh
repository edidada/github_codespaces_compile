#! /bin/bash
cd "$(dirname "$0")"
# 1. 下载源码（以2.1.12稳定版为例）
wget https://github.com/libevent/libevent/releases/download/release-2.1.12-stable/libevent-2.1.12-stable.tar.gz
# 2. 解压
tar -xzf libevent-2.1.12-stable.tar.gz
cd libevent-2.1.12-stable
mkdir build && cd build
cmake ../
make -j$(nproc)
sudo make install
cd ../ && rm -rf build
mkdir build && cd build
cmake .. -DEVENT__DISABLE_OPENSSL=ON
make -j$(nproc)
sudo make install