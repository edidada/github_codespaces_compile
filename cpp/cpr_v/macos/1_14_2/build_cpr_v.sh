#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch 1.14.2 https://github.com/libcpr/cpr.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
