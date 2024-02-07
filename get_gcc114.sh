#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt-get install libc6-dev libc6-dev-i386 -y
sudo apt install build-essential zlib1g-dev libncurses5-dev libssl-dev libreadline-dev libsqlite3-dev wget llvm -y
wget https://mirror.linux-ia64.org/gnu/gcc/releases/gcc-11.4.0/gcc-11.4.0.tar.gz -O gcc-11.4.0.tar.gz --no-check-certificate
ls -la gcc-11.4.0.tar.gz
tar xzvf gcc-11.4.0.tar.gz
cd gcc-11.4.0
./contrib/download_prerequisites
./configure --enable-languages=c,c++ --enable-multilib --with-system-zlib --with-system-bzlib --with-system-readline --with-system-sqlite --with-system-ncurses --with-system-libffi --with-plugindir=/usr/lib64/gcc/plugin --with-pkgversion="Ubuntu 20" --with-bugurl="https://bugs.ubuntu.com" --enable-shared --enable-static --enable-threads=posix --enable-checking=release --enable-optimizations --enable-lto-plugin --enable-libstdcxx-pch --enable-default-pie --enable-default-ssp --enable-libssp --enable-libgomp --enable-libquadmath --enable-libmpx --enable-libunwind --enable-libsanitizer=address,undefined CC=gcc CXX=g++
make all-gcc all-target-libgcc
sudo make install-gcc install-target-libgcc
