#!/bin/bash
cd "$(dirname "$0")"
git clone https://github.com/conan-io/conan.git conan_src
cd conan_src
git fetch --all
git checkout -b develop2 origin/develop2
python -m pip install -e .
