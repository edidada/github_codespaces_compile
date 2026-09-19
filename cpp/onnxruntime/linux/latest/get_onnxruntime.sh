#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update && sudo apt-get install -y git python3 python3-dev cmake ninja-build build-essential
git clone --depth 1 --recursive  https://github.com/microsoft/onnxruntime.git onnxruntime
cd onnxruntime
./build.sh --config Release --build_shared_lib --parallel 2 --skip_tests --compile_no_warning_as_error
