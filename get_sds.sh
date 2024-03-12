#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/antirez/sds.git
cd sds
make
sudo make install
