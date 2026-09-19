#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git python3-dev python3-venv build-essential cmake ninja-build
git clone --depth 1 --branch v0.29.0 https://github.com/vllm-project/vllm.git vllm
cd vllm
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip setuptools wheel cmake ninja
python -m pip install --index-url https://download.pytorch.org/whl/cpu torch
VLLM_TARGET_DEVICE=cpu python -m pip install --no-build-isolation -e .
python -c "import vllm; print(vllm.__version__)"
