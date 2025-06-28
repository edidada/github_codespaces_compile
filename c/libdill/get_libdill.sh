#! /bin/bash
sudo apt update
git clone https://github.com/sustrik/libdill
cd libdill
./configure
make
sudo make install