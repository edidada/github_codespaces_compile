#! /bin/bash
sudo apt-get update
cd "$(dirname "$0")"
git clone https://github.com/akimd/bison.git
cd bison
git checkout v3.8.2
git submodule update --init
./bootstrap
