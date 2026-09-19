#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git python3-dev python3-venv build-essential zip unzip
git clone --depth 1 --branch v2.21.0 https://github.com/tensorflow/tensorflow.git tensorflow
cd tensorflow
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip numpy wheel packaging requests opt_einsum
curl -fsSL -o bazelisk https://github.com/bazelbuild/bazelisk/releases/latest/download/bazelisk-linux-amd64
chmod +x bazelisk
export PYTHON_BIN_PATH="$PWD/.venv/bin/python"
export TF_NEED_CUDA=0
export TF_NEED_ROCM=0
export TF_NEED_TENSORRT=0
yes "" | ./configure
./bazelisk build --config=opt --jobs=2 //tensorflow/tools/pip_package:wheel
