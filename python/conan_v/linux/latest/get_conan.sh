#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
git clone --depth 1 --branch develop2 https://github.com/conan-io/conan.git conan_src
cd conan_src
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -e .
conan --version
