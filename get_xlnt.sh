#! /bin/bash
git clone https://github.com/tfussell/xlnt.git xlnt --recurse-submodules
cd xlnt
sudo apt-get update
sudo apt-get install zlibc -y
cmake .
make -j 2
sudo make install