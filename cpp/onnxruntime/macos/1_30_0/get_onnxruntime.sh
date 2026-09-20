#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
brew install cmake ninja python
git clone --depth 1 --recursive --branch v1.30.0 https://github.com/microsoft/onnxruntime.git onnxruntime
cd onnxruntime
./build.sh --config Release --build_shared_lib --parallel 2 --skip_tests --compile_no_warning_as_error
