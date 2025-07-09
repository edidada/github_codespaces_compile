#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
wget http://musl.libc.org/releases/musl-latest.tar.gz
tar -xzf musl-latest.tar.gz
cd musl-1.2.5/
./configure --prefix=/usr/local/musl
make
sudo make install
echo 'export PATH=/usr/local/musl/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
find . -name "musl-gcc"