#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch v1.5.0 --recurse-submodules https://github.com/tfussell/xlnt.git xlnt
cd xlnt
cmake -S . -B build -DSTATIC=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build --parallel
