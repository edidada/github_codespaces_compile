#! /bin/gcc
sudo yum update
sudo yum groupinstall "Development Tools"
sudo yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gdbm-devel db4-devel libpcap-devel xz-devel
wget https://ftp.gnu.org/gnu/gcc/gcc-11.2.0/gcc-11.2.0.tar.gz
ls -la gcc-11.2.0.tar.gz
tar -zxvf gcc-11.2.0.tar.gz
cd gcc-11.2.0
./contrib/download_prerequisites
./configure --enable-languages=c,c++ --disable-multilib --with-system-zlib --with-system-bzlib --with-system-readline --with-system-sqlite --with-system-ncurses --with-system-libffi --with-plugindir=/usr/lib64/gcc/plugin --with-pkgversion="CentOS 7.9" --with-bugurl="https://bugs.centos.org/taskman" --enable-shared --enable-static --enable-threads=posix --enable-checking=release --enable-optimizations --enable-lto-plugin --enable-libstdcxx-pch --enable-default-pie --enable-default-ssp --enable-libssp --enable-libgomp --enable-libquadmath --enable-libmpx --enable-libunwind --enable-libsanitizer=address,undefined CC=gcc CXX=g++
make all-gcc all-target-libgcc
sudo make install-gcc install-target-libgcc