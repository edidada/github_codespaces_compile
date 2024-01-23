#! /bin/bash
git clone https://github.com/tfussell/xlnt.git xlnt --recurse-submodules
cd xlnt
sudo brew install zlibc
cmake .
make -j 2
sudo make install
