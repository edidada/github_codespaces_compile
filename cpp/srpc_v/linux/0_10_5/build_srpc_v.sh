#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --recurse-submodules --branch v0.10.5 https://github.com/sogou/srpc.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
