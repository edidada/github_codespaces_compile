$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v0.26.1 https://github.com/sharkdp/bat.git project
Set-Location project
cargo build --workspace --release
