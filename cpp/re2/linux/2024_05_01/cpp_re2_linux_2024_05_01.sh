#!/bin/bash
cd "$(dirname "$0")"
sudo apt install -y libabsl-dev
git clone https://github.com/google/re2.git
cd re2
git checkout 2024-05-01
make -j$(nproc)
sudo make install