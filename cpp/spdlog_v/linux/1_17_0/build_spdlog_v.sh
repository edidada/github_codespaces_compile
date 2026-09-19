#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch v1.17.0 https://github.com/gabime/spdlog.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
