#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --recurse-submodules https://github.com/sogou/srpc.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
