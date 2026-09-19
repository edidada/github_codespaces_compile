#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake ninja llvm@20
git clone --depth 1 --recursive --branch v0.26.0 https://github.com/apache/tvm.git tvm
cd tvm
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DUSE_LLVM="$(brew --prefix llvm@20)/bin/llvm-config"
cmake --build build --parallel 2
