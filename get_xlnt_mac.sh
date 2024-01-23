#! /bin/bash
git clone https://github.com/tfussell/xlnt.git xlnt --recurse-submodules
cd xlnt
mkdir build && cd build
cmake -D STATIC=ON -G Xcode ..
cmake --build .
sudo make install
cd bin && ./xlnt.test
