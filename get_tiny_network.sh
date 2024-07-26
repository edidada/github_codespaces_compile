#!/bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install cmake -y
git clone https://github.com/Shangyizhou/A-Tiny-Network-Library.git
cd ./A-Tiny-Network-Library && chmod +x build.sh && sudo ./build.sh