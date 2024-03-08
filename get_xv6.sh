#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/mit-pdos/xv6-public.git
cd xv6-public
make
sudo apt update
LC_ALL=C lscpu | grep Virtualization
sudo apt install qemu qemu-kvm virt-manager bridge-utils -y
make qemu