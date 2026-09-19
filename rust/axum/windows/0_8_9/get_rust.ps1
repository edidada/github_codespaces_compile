$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch axum-v0.8.9 https://github.com/tokio-rs/axum.git project
Set-Location project
cargo build --workspace --release
