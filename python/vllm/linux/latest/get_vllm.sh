#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git python3-dev python3-venv build-essential cmake ninja-build libnuma-dev
git clone --depth 1  https://github.com/vllm-project/vllm.git vllm
cd vllm
# GitHub-hosted GCC does not yet implement AVX10.2.  vLLM has a complete
# AVX512 fallback, so disable just the optional AVX10.2 dispatch and code path
# while retaining the portable CPU extension.
sed -i 's/__builtin_cpu_supports("avx10.2")/false/' csrc/cpu/sgl-kernels/common.h
sed -i 's/__attribute__((target("avx10.2"))) //g; s/_mm256_cvtph_hf8(_mm256_castsi256_ph(f16_vec))/cvtfp32_fp8e4m3(src)/' \
  csrc/cpu/sgl-kernels/gemm_fp8_w8a8.cpp
python3 -m venv .venv
source .venv/bin/activate
python -m pip install --upgrade pip 'setuptools>=77,<81' wheel cmake ninja numpy packaging jinja2 setuptools-scm setuptools-rust
python -m pip install --index-url https://download.pytorch.org/whl/cpu torch==2.13.0
VLLM_TARGET_DEVICE=cpu python -m pip install --no-build-isolation -e .
python -c "import vllm; print(vllm.__version__)"
