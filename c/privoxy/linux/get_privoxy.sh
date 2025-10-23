#! /bin/bash
git clone https://www.privoxy.org/git/privoxy.git
cd privoxy
autoheader
autoconf
./configure
make -j4
sudo make -n install
