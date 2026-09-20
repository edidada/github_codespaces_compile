#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git cmake ninja-build build-essential llvm-dev python3-dev
git clone --depth 1 --recursive --branch v0.26.0 https://github.com/apache/tvm.git tvm
cd tvm
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_LLVM=llvm-config
cmake --build build --parallel 2
