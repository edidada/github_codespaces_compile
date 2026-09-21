#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git python3-dev python3-venv build-essential cmake ninja-build libnuma-dev
git clone --depth 1  https://github.com/vllm-project/vllm.git vllm
cd vllm
# GitHub-hosted compilers may not yet recognize vLLM's AVX10.2 feature
# probe.  It is an optional runtime optimization, so disable only that probe
# until the hosted toolchain catches up.
sed -i 's/__builtin_cpu_supports("avx10.2")/false/' csrc/cpu/sgl-kernels/common.h
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip 'setuptools>=77,<81' wheel cmake ninja numpy packaging jinja2 setuptools-scm setuptools-rust
python -m pip install --index-url https://download.pytorch.org/whl/cpu torch==2.13.0
VLLM_TARGET_DEVICE=cpu python -m pip install --no-build-isolation -e .
python -c "import vllm; print(vllm.__version__)"
