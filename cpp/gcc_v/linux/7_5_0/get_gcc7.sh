#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
set -e

echo "=== Ubuntu 22.04 快速源码编译 GCC 7 ==="

# 安装最小依赖
sudo apt update
sudo apt install -y build-essential wget make
sudo apt install -y libgmp-dev libmpfr-dev libmpc-dev

# 创建工作目录
mkdir -p gcc-build && cd gcc-build

# 下载源码
wget https://ftp.gnu.org/gnu/gcc/gcc-7.5.0/gcc-7.5.0.tar.gz
tar -zxvf gcc-7.5.0.tar.gz
cd gcc-7.5.0

# 下载依赖
./contrib/download_prerequisites

# 配置和编译
mkdir build && cd build
../configure --prefix=/usr/local/gcc-7.5.0 --enable-languages=c,c++ --disable-multilib
make -j$(nproc)
sudo make install

# 设置环境
echo 'export PATH=/usr/local/gcc-7.5.0/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

echo "✅ GCC 7.5.0 编译安装完成"