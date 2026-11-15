$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
rustup toolchain install stable --profile minimal
rustup default stable
$vcpkgRoot = if ($env:VCPKG_INSTALLATION_ROOT) { $env:VCPKG_INSTALLATION_ROOT } else { 'C:\vcpkg' }
& (Join-Path $vcpkgRoot 'vcpkg.exe') install openssl:x64-windows
$env:VCPKG_ROOT = $vcpkgRoot
$env:OPENSSL_DIR = Join-Path $vcpkgRoot 'installed\x64-windows'
$env:OPENSSL_LIB_DIR = Join-Path $env:OPENSSL_DIR 'lib'
$env:OPENSSL_INCLUDE_DIR = Join-Path $env:OPENSSL_DIR 'include'
git clone --depth 1 --branch axum-v0.8.9 https://github.com/tokio-rs/axum.git project
Set-Location project
cargo build --release -p axum -p axum-core -p axum-extra
