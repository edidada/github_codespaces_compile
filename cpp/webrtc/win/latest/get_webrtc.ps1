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

# WebRTC main can move to a newer Windows SDK before the GitHub-hosted image
# provides it. Prefer main when compatible; otherwise select the newest
# branch-head that targets an SDK actually installed on the runner.
$sdkRoot = Join-Path ${env:ProgramFiles(x86)} 'Windows Kits\10'
$installedSdks = @(
    Get-ChildItem (Join-Path $sdkRoot 'Include') -Directory |
        Where-Object { Test-Path (Join-Path $_.FullName 'um') } |
        Sort-Object { [version]$_.Name } -Descending |
        Select-Object -ExpandProperty Name
)
if ($installedSdks.Count -eq 0) {
    throw "No usable Windows 10/11 SDK was found under $sdkRoot"
}

$toolchainFile = 'build/vs_toolchain.py'
$requiredSdkMatch = Select-String -Path $toolchainFile -Pattern "^SDK_VERSION\s*=\s*'([^']+)'"
$requiredSdk = if ($requiredSdkMatch) { $requiredSdkMatch.Matches[0].Groups[1].Value } else { '' }
$selectedSdk = $requiredSdk

if ($requiredSdk -notin $installedSdks) {
    git fetch origin '+refs/branch-heads/*:refs/remotes/branch-heads/*' --depth=1
    $compatibleRef = $null
    # Some refs/branch-heads entries are temporary test branches and do not
    # contain the Chromium toolchain file. A missing file is a normal probe
    # result here, not a build failure.
    $PSNativeCommandUseErrorActionPreference = $false
    foreach ($ref in (git for-each-ref '--sort=-version:refname' '--format=%(refname)' 'refs/remotes/branch-heads/*')) {
        $toolchainText = git show "${ref}:${toolchainFile}" 2>$null
        if ($LASTEXITCODE -ne 0) {
            continue
        }
        foreach ($sdk in $installedSdks) {
            if ($toolchainText -match "SDK_VERSION\s*=\s*'$([regex]::Escape($sdk))'") {
                $compatibleRef = $ref
                $selectedSdk = $sdk
                break
            }
        }
        if ($compatibleRef) {
            break
        }
    }
    $PSNativeCommandUseErrorActionPreference = $true
    if (-not $compatibleRef) {
        throw "No WebRTC branch-head supports an installed SDK: $($installedSdks -join ', ')"
    }
    Write-Host "WebRTC main requires SDK $requiredSdk; using $compatibleRef with SDK $selectedSdk"
    git checkout -B ci-sdk-compatible $compatibleRef
} else {
    Write-Host "WebRTC main is compatible with installed SDK $requiredSdk"
}

$env:WindowsSdkDir = "$sdkRoot\"
$env:WindowsSDKVersion = "$selectedSdk\"
Set-Location ..
gclient sync --reset --force --delete_unversioned_trees --no-history
Set-Location src
gn gen out/Release --args='is_debug=false rtc_include_tests=false rtc_build_examples=false'
autoninja.bat -C out/Release webrtc
