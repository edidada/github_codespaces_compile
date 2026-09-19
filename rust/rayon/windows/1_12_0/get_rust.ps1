$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v1.12.0 https://github.com/rayon-rs/rayon.git project
Set-Location project
cargo build --workspace --release
