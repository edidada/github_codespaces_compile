#! /bin/bash
sudo apt-get update
sudo apt-get install -y build-essential autoconf libtool
git clone https://github.com/happyfish100/fastdfs.git
cd fastdfs
./make.sh
./configure
make
