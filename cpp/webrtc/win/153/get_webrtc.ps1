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
$env:DEPOT_TOOLS_WIN_TOOLCHAIN = '0'
gclient.bat --version
New-Item -ItemType Directory -Path webrtc-checkout | Out-Null
Set-Location webrtc-checkout
fetch.bat --nohooks webrtc
Set-Location src
git checkout -b m153 refs/remotes/branch-heads/8010
gclient sync --reset --force --delete_unversioned_trees --no-history

# The m153 branch currently pins a newer Windows SDK than GitHub's hosted
# Windows 2022 image provides.  Use the newest SDK installed on the runner so
# the hosted Visual Studio toolchain can be configured consistently.
$sdkRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10'
$selectedSdk = Get-ChildItem (Join-Path $sdkRoot 'Include') -Directory |
    Where-Object { Test-Path (Join-Path $_.FullName 'um') } |
    Sort-Object { [version]$_.Name } -Descending |
    Select-Object -First 1 -ExpandProperty Name
if (-not $selectedSdk) {
    throw "No usable Windows SDK was found under $sdkRoot"
}

$toolchainFile = 'build/vs_toolchain.py'
$toolchainText = Get-Content -Raw $toolchainFile
if ($toolchainText -notmatch 'SDK_VERSION\s*=\s*[''\"][^''\"]+[''\"]') {
    throw "Could not find SDK_VERSION in $toolchainFile"
}
$toolchainText = $toolchainText -replace 'SDK_VERSION\s*=\s*[''\"][^''\"]+[''\"]', "SDK_VERSION = '$selectedSdk'"
Set-Content -NoNewline -Encoding utf8NoBOM -Path $toolchainFile -Value $toolchainText
# VS's generated environment files can retain the SDK revision originally
# selected by the branch.  GN passes one of these files to setup_toolchain.py,
# so rewrite the stale paths as well as SDK_VERSION.
Get-ChildItem 'build/toolchain/win' -Filter 'environment.*' -File | ForEach-Object {
    $environmentText = Get-Content -Raw $_.FullName
    $environmentText = $environmentText -replace '10\.0\.28000\.0', $selectedSdk
    Set-Content -NoNewline -Encoding utf8NoBOM -Path $_.FullName -Value $environmentText
}
$env:WindowsSdkDir = "$sdkRoot\"
$env:WindowsSDKVersion = "$selectedSdk\"
Write-Host "Using installed Windows SDK $selectedSdk"

gn gen out/Release --args='is_debug=false rtc_include_tests=false rtc_build_examples=false'
autoninja.bat -C out/Release webrtc
