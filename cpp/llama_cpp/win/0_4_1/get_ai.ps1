$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
git clone --depth 1 --recursive --branch v0.4.1 https://github.com/ggml-org/llama.cpp.git project
Set-Location project
cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DGGML_NATIVE=OFF -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF
cmake --build build --config Release --parallel 2
