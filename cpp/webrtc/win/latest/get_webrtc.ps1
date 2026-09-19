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
$sdkPattern = 'SDK_VERSION\s*=\s*[''"]([^''"]+)[''"]'
$requiredSdkMatch = Select-String -Path $toolchainFile -Pattern $sdkPattern
$requiredSdk = if ($requiredSdkMatch) { $requiredSdkMatch.Matches[0].Groups[1].Value } else { '' }
$selectedSdk = $requiredSdk

if ($requiredSdk -notin $installedSdks) {
    git fetch origin '+refs/branch-heads/*:refs/remotes/branch-heads/*' --depth=1
    $compatibleRef = $null
    # build/ is a separate repository pinned by WebRTC's DEPS file, so it
    # cannot be read with `git show <webrtc-ref>:build/vs_toolchain.py`.
    # Resolve that pinned build revision for each branch-head and inspect the
    # toolchain file in the already-synced build dependency repository.
    $PSNativeCommandUseErrorActionPreference = $false
    foreach ($ref in (git for-each-ref '--sort=-version:refname' '--format=%(refname)' 'refs/remotes/branch-heads/*')) {
        $depsText = (git show "${ref}:DEPS" 2>$null) -join "`n"
        if ($LASTEXITCODE -ne 0) {
            continue
        }
        if ($depsText -notmatch "(?ms)'src/build'\s*:\s*'[^']+@([0-9a-f]{40})'") {
            continue
        }
        $buildRevision = $Matches[1]
        git -C build fetch origin $buildRevision --depth=1 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            continue
        }
        $toolchainText = (git -C build show "${buildRevision}:vs_toolchain.py" 2>$null) -join "`n"
        $candidateMatch = [regex]::Match($toolchainText, $sdkPattern)
        if ($LASTEXITCODE -ne 0 -or -not $candidateMatch.Success) {
            continue
        }
        $candidateSdk = $candidateMatch.Groups[1].Value
        if ($candidateSdk -in $installedSdks) {
            $compatibleRef = $ref
            $selectedSdk = $candidateSdk
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
