#!/usr/bin/env bash
set -euo pipefail
sudo apt-get update
sudo apt-get install -y libcurl4-openssl-dev
git clone --depth 1  https://github.com/pistacheio/pistache.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DPISTACHE_BUILD_TESTS=OFF
cmake --build build --parallel
