$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot
git clone --depth 1 --recursive --branch v1.30.0 https://github.com/microsoft/onnxruntime.git onnxruntime
Set-Location onnxruntime
.\build.bat --config Release --build_shared_lib --parallel 2 --skip_tests --compile_no_warning_as_error
