#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1  --branch v0.4.25 https://github.com/pistacheio/pistache.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
