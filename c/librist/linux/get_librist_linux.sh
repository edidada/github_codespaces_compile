#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://code.videolan.org/rist/librist.git
cd librist
sudo apt install -y meson ninja-build
git checkout v0.2.9
meson setup --prefix=/usr/local ./build
cd build
ninja
sudo ninja install
cd ../../