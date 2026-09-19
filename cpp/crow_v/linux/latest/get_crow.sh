#!/usr/bin/env bash
set -euo pipefail
sudo apt update
apt-cache showpkg libboost-all-dev
sudo apt install build-essential zlib1g-dev libncurses5-dev libssl-dev libreadline-dev libsqlite3-dev wget llvm libboost-all-dev -y
git clone -b v1.0+5 https://github.com/CrowCpp/Crow.git
cd Crow
cmake -S . -B build -DCROW_DISABLE_SSL=TRUE -DCROW_DISABLE_AMALGAMATION=TRUE -DCROW_DISABLE_COMPRESSION=TRUE -DCROW_BUILD_EXAMPLES=OFF -DCROW_BUILD_TESTS=OFF
cmake --build build --parallel
