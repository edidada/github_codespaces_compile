#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install build-essential git libc6-dev-i386 zlib1g-dev libncurses5-dev libssl-dev libreadline-dev libsqlite3-dev wget llvm -y
wget https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
ls -la gcc-11.2.0.tar.gz
tar -zxvf gcc-11.2.0.tar.gz
cd gcc-11.2.0
./contrib/download_prerequisites
./configure --enable-languages=c,c++ --enable-multilib --with-system-zlib --with-system-bzlib --with-system-readline --with-system-sqlite --with-system-ncurses --with-system-libffi --with-plugindir=/usr/lib64/gcc/plugin --with-pkgversion="Ubuntu 20" --with-bugurl="https://bugs.ubuntu.com" --enable-shared --enable-static --enable-threads=posix --enable-checking=release --enable-optimizations --enable-lto-plugin --enable-libstdcxx-pch --enable-default-pie --enable-default-ssp --enable-libssp --enable-libgomp --enable-libquadmath --enable-libmpx --enable-libunwind --enable-libsanitizer=address,undefined CC=gcc CXX=g++
make all-gcc all-target-libgcc
sudo make install-gcc install-target-libgcc