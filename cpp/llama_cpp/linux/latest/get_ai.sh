#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update && sudo apt-get install -y git cmake ninja-build build-essential
git clone --depth 1 --recursive  https://github.com/ggml-org/llama.cpp.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF
cmake --build build --config Release --parallel 2
