$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
Set-Location $PSScriptRoot
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$env:PATH = "$PWD\depot_tools;$env:PATH"
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = '0'
gclient.bat --version
New-Item -ItemType Directory -Path webrtc-checkout | Out-Null
Set-Location webrtc-checkout
fetch.bat --nohooks webrtc
Set-Location src
git checkout -b m153 refs/remotes/branch-heads/8010
gclient sync --reset --force --delete_unversioned_trees --no-history
gn gen out/Release --args='is_debug=false rtc_include_tests=false rtc_build_examples=false'
autoninja.bat -C out/Release webrtc
