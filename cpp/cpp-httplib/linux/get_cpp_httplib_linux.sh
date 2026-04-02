#! /bin/bash
cd "$(dirname "$0")"
sudo apt update
git clone https://github.com/yhirose/cpp-httplib.git
cd cpp-httplib
git checkout v0.11.0
pip3 install meson
sudo apt-get install ninja-build libbrotli-dev openssl -y
meson setup build
cd build
meson compile -j 6