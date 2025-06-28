#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone https://github.com/antirez/sds.git
cd sds
make
