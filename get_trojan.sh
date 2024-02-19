#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get install trojan
sudo apt-get update
echo "git clone boost"
git clone -b boost-1.66.0 https://github.com/boostorg/boost.git
cd boost*/
echo "git submodule"
git submodule init
git submodule update
echo "run bootstrap script"
./bootstrap.sh --with-libraries=all
sudo ./b2 install
./b2 --show-libraries
sudo ldconfig
cd ..
git clone https://github.com/trojan-gfw/trojan.git
cd trojan/
mkdir build
cd build/
cmake ..
make
ctest
sudo make install
