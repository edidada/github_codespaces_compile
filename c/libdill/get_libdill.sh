#! /bin/bash
sudo apt update
git clone https://github.com/sustrik/libdill.git
cd libdill
./autogen.sh
./configure
make
sudo make install