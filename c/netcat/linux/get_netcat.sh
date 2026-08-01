#! /bin/bash
cd "$(dirname "$0")"
wget -O netcat-0.7.1.tar.gz https://zenlayer.dl.sourceforge.net/project/netcat/netcat/0.7.1/netcat-0.7.1.tar.gz?viasf=1
tar -zxvf netcat-0.7.1.tar.gz
cd netcat-0.7.1/
chmod +x configure
./configure
make
sudo make install
