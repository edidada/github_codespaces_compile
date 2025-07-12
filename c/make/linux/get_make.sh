#! /bin/bash
sudo apt update
wget https://ftp.gnu.org/gnu/make/make-4.3.tar.gz
cd make-4.3
./configure
make -j4
