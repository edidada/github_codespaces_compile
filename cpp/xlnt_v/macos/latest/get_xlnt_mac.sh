#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --recurse-submodules https://github.com/tfussell/xlnt.git xlnt
cd xlnt

# libstudxml ships a metadata file named "version". New libc++ headers include
# <version>, and the third-party include path shadows the standard header.
if [[ -f third-party/libstudxml/version ]]; then
  mv third-party/libstudxml/version third-party/libstudxml/version.txt
fi

cmake -S . -B build -DSTATIC=ON -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build build --parallel
