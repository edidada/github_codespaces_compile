$ErrorActionPreference = 'Stop'
$PSNativeCommandUseErrorActionPreference = $true
git config --global core.longpaths true
git config --global core.autocrlf false
git config --global depot-tools.allowGlobalGitConfig false
$workRoot = Join-Path $env:RUNNER_TEMP "webrtc-$env:GITHUB_RUN_ID"
New-Item -ItemType Directory -Force -Path $workRoot | Out-Null
Set-Location $workRoot
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
$env:PATH = "$PWD\depot_tools;$env:PATH"
# Let depot_tools provision the toolchain pinned by the checked-out Chromium branch.
# The hosted Visual Studio/Windows SDK can be newer than this branch and causes
# incompatible Windows header combinations during the native build.
Remove-Item Env:DEPOT_TOOLS_WIN_TOOLCHAIN -ErrorAction SilentlyContinue
gclient.bat --version
New-Item -ItemType Directory -Path webrtc-checkout | Out-Null
Set-Location webrtc-checkout
fetch.bat --nohooks webrtc
Set-Location src
git checkout -b m153 refs/remotes/branch-heads/8010
gclient sync --reset --force --delete_unversioned_trees --no-history
gn gen out/Release --args='is_debug=false rtc_include_tests=false rtc_build_examples=false'
autoninja.bat -C out/Release webrtc
