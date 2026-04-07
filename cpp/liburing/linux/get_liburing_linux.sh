#! /bin/bash
TOTAL_RAM=$(free -h | awk '/^Mem:/ {print $2}')
echo "local sys (RAM) is: $TOTAL_RAM"
sudo apt update
git clone https://github.com/axboe/liburing.git
cd liburing
git checkout liburing-2.10
./configure --cc=gcc --cxx=g++
make -j$(nproc)
make liburing.pc
sudo make install