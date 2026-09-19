$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch 1.58.0 https://github.com/casey/just.git project
Set-Location project
cargo build --workspace --release
