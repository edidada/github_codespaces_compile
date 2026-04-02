#! /bin/bash
sudo yum update
sudo yum install glibc-devel libstdc++-devel gcc-c++ binutils zlib-devel libmpc-devel mpfr-devel -y
# wget https://mirror.linux-ia64.org/gnu/gcc/releases/gcc-10.5.0/gcc-10.5.0.tar.gz -O gcc-10.5.0.tar.gz --no-check-certificate
wget https://ftp.gnu.org/gnu/gcc/gcc-10.5.0/gcc-10.5.0.tar.gz -O gcc-10.5.0.tar.gz --no-check-certificate
ls -la gcc-10.5.0.tar.gz
tar xzvf gcc-10.5.0.tar.gz
cd gcc-10.5.0
./contrib/download_prerequisites
./configure --enable-languages=c,c++ --disable-multilib --with-system-zlib --with-system-bzlib --with-system-readline --with-system-sqlite --with-system-ncurses --with-system-libffi --with-plugindir=/usr/lib64/gcc/plugin --with-pkgversion="Ubuntu 20" --with-bugurl="https://bugs.ubuntu.com" --enable-shared --enable-static --enable-threads=posix --enable-checking=release --enable-optimizations --enable-lto-plugin --enable-libstdcxx-pch --enable-default-pie --enable-default-ssp --enable-libssp --enable-libgomp --enable-libquadmath --enable-libmpx --enable-libunwind --enable-libsanitizer=address,undefined CC=gcc CXX=g++
make all-gcc all-target-libgcc
sudo make install-gcc install-target-libgcc