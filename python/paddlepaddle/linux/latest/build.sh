#!/usr/bin/env bash
set -euo pipefail
work_root="${RUNNER_TEMP:-/tmp}/paddlepaddle-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
git clone --depth=1 https://github.com/PaddlePaddle/Paddle.git "$work_root"
cd "$work_root"

sudo apt-get update
sudo apt-get install -y build-essential cmake ninja-build python3-dev
python -m pip install --upgrade pip numpy protobuf wheel setuptools
python -m pip install --upgrade -r python/requirements.txt

# CPU-only compilation is reproducible on a hosted Linux runner and still
# builds Paddle's native C++ core; CUDA is intentionally disabled here.
cmake -S . -B build -G Ninja \
  -DWITH_GPU=OFF -DWITH_ROCM=OFF -DWITH_TESTING=OFF -DWITH_DISTRIBUTE=OFF \
  -DWITH_INFERENCE_API_TEST=OFF -DCMAKE_BUILD_TYPE=Release
cmake --build build --parallel 2
test -n "$(find build -type f \( -name 'libpaddle*.so' -o -name 'paddle' \) -print -quit)"
