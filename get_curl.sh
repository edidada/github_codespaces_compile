#! /bin/bash
git clone https://github.com/curl/curl.git
cd curl
git checkout curl-8_5_0
./configure
make
sudo make install