$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v0.13.5 https://github.com/seanmonstar/reqwest.git project
Set-Location project
cargo build --workspace --release
