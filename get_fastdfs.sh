#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/happyfish100/libfastcommon.git
cd libfastcommon
git checkout V1.0.56
./make.sh clean && ./make.sh && sudo ./make.sh install
cd ../
git clone https://github.com/happyfish100/fastdfs.git
cd fastdfs
git checkout V6.08
./make.sh clean && ./make.sh && sudo ./make.sh install
./setup.sh /etc/fdfs