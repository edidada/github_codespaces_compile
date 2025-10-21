#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y build-essential libncurses5-dev libstdc++6 gawk bison
wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.gz
tar xzf glibc-2.29.tar.gz
cd glibc-2.29
mkdir build
cd build
../configure --prefix=/opt/glibc-2.29
make -j4  # 使用4个并行任务编译以加快速度
sudo make install
/opt/glibc-2.29/lib/ld-linux-x86-64.so.2 --version