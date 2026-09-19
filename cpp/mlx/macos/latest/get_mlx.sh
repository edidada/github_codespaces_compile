#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake ninja python
git clone --depth 1 --recursive  https://github.com/ml-explore/mlx.git mlx
cd mlx
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel nanobind
CMAKE_BUILD_PARALLEL_LEVEL=2 python -m pip install --no-build-isolation -e .
python -c "import mlx.core as mx; print(mx.array([1, 2, 3]))"
