#! /bin/bash
sudo apt-get update
sudo apt-get install autoconf automake m4 libtool -y
git clone https://github.com/curl/curl.git
cd curl
git checkout curl-8_5_0
autoconf --with-openssl
chmod +x configure
./configure --with-openssl
make
sudo make install