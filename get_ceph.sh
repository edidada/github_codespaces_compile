#! /bin/bash
cd "$(dirname "$0")"
git clone -b v15.2.17 https://github.com/ceph/ceph.git
cd ceph
git submodule update --init --recursive --progress
sudo apt update
sudo apt install curl -y
sudo apt install python3-routes -y
./install-deps.sh
./do_cmake.sh
cd build
ninja