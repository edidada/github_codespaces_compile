#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update && sudo apt-get install -y git cmake ninja-build build-essential
git clone --depth 1 --recursive --branch v1.9.4 https://github.com/ggml-org/whisper.cpp.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DWHISPER_BUILD_TESTS=OFF -DWHISPER_BUILD_EXAMPLES=OFF
cmake --build build --config Release --parallel 2
