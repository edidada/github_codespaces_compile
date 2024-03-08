#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/mit-pdos/xv6-public.git
cd xv6-public
make
sudo apt update
sudo apt install qemu -y
make qemu