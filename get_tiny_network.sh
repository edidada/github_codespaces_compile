#!/bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install cmake -y
git clone git@github.com:Shangyizhou/tiny-network.git
cd ./tiny-network && bash build.sh