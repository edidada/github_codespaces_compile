#! /bin/bash
sudo apt update
git clone https://github.com/ETLCPP/etl.git
cd etl
cmake -B build
cmake --build build