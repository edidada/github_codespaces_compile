$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
git clone --depth 1 --branch v10.5.0 https://github.com/sharkdp/fd.git project
Set-Location project
cargo build --workspace --release
