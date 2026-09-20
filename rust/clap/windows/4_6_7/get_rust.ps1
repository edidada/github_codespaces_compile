$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v4.6.7 https://github.com/clap-rs/clap.git project
Set-Location project
cargo build --workspace --release
