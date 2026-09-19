#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch 12.2.0 https://github.com/fmtlib/fmt.git project
cd project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel
