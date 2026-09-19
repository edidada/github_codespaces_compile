param(
    [ValidateSet('apache', 'cncf')]
    [string]$Foundation = 'apache',
    [string]$SourceRepo = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$RunnerRepo = 'D:\develops\git\github\github_codespaces_compile\_codex_branch_migration\runner'
)

$ErrorActionPreference = 'Stop'

function ConvertTo-Slug {
    param([string]$Value)
    (($Value.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_'))
}

function ConvertTo-VersionSlug {
    param([string]$Value)
    $slug = ConvertTo-Slug ($Value -replace '^(?i)(release|rel|version|ver|v)[-_/ ]*', '')
    if ($slug) { $slug } else { 'stable' }
}

function Get-NumericVersionKey {
    param([string]$Value)
    if ($Value -match '(?i)(\d+(?:[._-]\d+){1,3})') {
        return ($Matches[1] -replace '[._-]', '_')
    }
}

function ConvertTo-LanguageSlug {
    param([string]$Value)
    switch -Regex ($Value) {
        'C\+\+' { 'cpp'; break }
        '^C#|C Sharp' { 'csharp'; break }
        'Objective-C' { 'objective_c'; break }
        '^C$' { 'c'; break }
        'JavaScript' { 'javascript'; break }
        'TypeScript' { 'typescript'; break }
        'ActionScript' { 'actionscript'; break }
        'Jupyter' { 'python'; break }
        'Python' { 'python'; break }
        'Java' { 'java'; break }
        'Kotlin' { 'kotlin'; break }
        'Scala' { 'scala'; break }
        'Groovy' { 'groovy'; break }
        'Go' { 'go'; break }
        'Rust' { 'rust'; break }
        'Ruby' { 'ruby'; break }
        'PHP' { 'php'; break }
        'Perl' { 'perl'; break }
        'Erlang' { 'erlang'; break }
        'Elixir' { 'elixir'; break }
        'Swift' { 'swift'; break }
        'Lua' { 'lua'; break }
        'Shell' { 'shell'; break }
        'HTML|CSS|Vue|Svelte' { 'web'; break }
        default { if ($Value) { ConvertTo-Slug $Value } else { 'misc' } }
    }
}

function ConvertTo-BashLiteral {
    param([AllowEmptyString()][string]$Value)
    $singleQuote = [char]39
    $replacement = "$singleQuote\$singleQuote$singleQuote"
    "$singleQuote$($Value.Replace([string]$singleQuote, $replacement))$singleQuote"
}

function Set-Utf8File {
    param([string]$Path, [string]$Content)
    $directory = Split-Path -Parent $Path
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    Set-Content -LiteralPath $Path -Value $Content -Encoding utf8NoBOM
}

$catalogPath = Join-Path $SourceRepo "catalogs\foundations\$($Foundation -eq 'apache' ? 'apache-projects.json' : 'cncf-active-projects.json')"
$projects = @(Get-Content $catalogPath -Raw | ConvertFrom-Json)
$specifications = [System.Collections.Generic.List[object]]::new()
$buildRootOverrides = @{
    'apache:opendal' = 'core'
}
$projectNotes = @{
    'apache:opendal' = 'OpenDAL is a multi-language umbrella repository. The primary Rust workspace is under `core/`, so this target selects that build root explicitly.'
    'apache:incubator-pouchdb' = 'This historical PouchDB codebase uses Node.js 18 because its legacy build plugins are not compatible with Node.js 22 on current GitHub-hosted runners.'
}

foreach ($project in $projects) {
    if ($Foundation -eq 'apache') {
        $key = [string]$project.key
        $name = [string]$project.name
        $repository = [string]$project.primary_repository
        $languageValue = [string]$project.detected_language
        if (-not $languageValue) { $languageValue = [string]@($project.language)[0] }
        $product = "apache_$(ConvertTo-Slug $key)"
        $officialRelease = [string]$project.stable_release
        $candidateTag = [string]$project.stable_tag
        $stableVersion = ''
        $stableRef = ''
        $prereleasePattern = '(?i)(alpha|beta|preview|pre|rc|nightly|snapshot|dev|milestone|(?:^|[-_.])m\d+)'
        if (
            $officialRelease -and
            $candidateTag -and
            $officialRelease -notmatch $prereleasePattern -and
            $candidateTag -notmatch $prereleasePattern
        ) {
            $releaseVersionKey = Get-NumericVersionKey $officialRelease
            $tagVersionKey = Get-NumericVersionKey $candidateTag
            $normalizedRelease = ConvertTo-Slug $officialRelease
            $normalizedTag = ConvertTo-Slug $candidateTag
            if (
                ($releaseVersionKey -and $releaseVersionKey -eq $tagVersionKey) -or
                ($normalizedRelease -and $normalizedTag.Contains($normalizedRelease))
            ) {
                $stableVersion = if ($releaseVersionKey) { $releaseVersionKey } else { $normalizedRelease }
                $stableRef = $candidateTag
            }
        }
    } else {
        $key = ConvertTo-Slug ([string]$project.name)
        $name = [string]$project.name
        $repository = [string]$project.repository
        $languageValue = [string]$project.language
        $product = "cncf_$key"
        $stableVersion = [string]$project.stable_tag
        $stableRef = [string]$project.stable_tag
    }

    $language = ConvertTo-LanguageSlug $languageValue
    $versions = @([pscustomobject]@{ Version = 'latest'; Ref = '' })
    if ($stableRef) {
        $versions += [pscustomobject]@{
            Version = ConvertTo-VersionSlug ($(if ($stableVersion) { $stableVersion } else { $stableRef }))
            Ref = $stableRef
        }
    }

    foreach ($versionSpec in @($versions | Sort-Object Version -Unique)) {
        $version = [string]$versionSpec.Version
        $branch = "$language/$product/linux/$version"
        $relativeDirectory = $branch -replace '/', [IO.Path]::DirectorySeparatorChar
        $scriptRelative = "$branch/build.sh"
        $scriptPath = Join-Path $SourceRepo ($scriptRelative -replace '/', [IO.Path]::DirectorySeparatorChar)
        $readmePath = Join-Path $SourceRepo (Join-Path $relativeDirectory 'README.md')
        $workflowFile = "${language}_${product}_linux_${version}.yml"
        $workflowPath = Join-Path $RunnerRepo ".github\workflows\$workflowFile"
        $overrideKey = "$Foundation`:$key"
        $buildRoot = [string]$buildRootOverrides[$overrideKey]
        $buildRootLine = if ($buildRoot) { "export PROJECT_BUILD_ROOT=$(ConvertTo-BashLiteral $buildRoot)" } else { '' }

        $wrapper = @"
#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME=$(ConvertTo-BashLiteral $name)
export PROJECT_REPOSITORY=$(ConvertTo-BashLiteral $repository)
export PROJECT_VERSION=$(ConvertTo-BashLiteral $version)
export PROJECT_REF=$(ConvertTo-BashLiteral ([string]$versionSpec.Ref))
$buildRootLine
repository_root="`$(cd "`$(dirname "`${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "`$repository_root/tools/foundations/build_project.sh"
"@
        Set-Utf8File $scriptPath $wrapper

        $readme = @"
# $name — Linux $version

- Foundation catalog: $Foundation
- Source repository: $repository
- Checkout ref: $(if ($versionSpec.Ref) { $versionSpec.Ref } else { 'repository default branch' })
- Detected language: $(if ($languageValue) { $languageValue } else { 'unspecified' })
- Build policy: clone the requested revision and run the repository's native build and test system through ``tools/foundations/build_project.sh``.

The branch and path follow ``编程语言/软件名称/操作系统/版本``. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
"@
        if ($projectNotes.ContainsKey($overrideKey)) {
            $readme += "`r`n$($projectNotes[$overrideKey])`r`n"
        }
        Set-Utf8File $readmePath $readme

        $setupSteps = ''
        if ($overrideKey -eq 'apache:incubator-pouchdb') {
            $setupSteps = @"
      - name: Set up compatible Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
"@
        }

        $workflow = @"
name: build $branch

on:
  push:
    branches:
      - '$branch'
  pull_request:
    branches:
      - '$branch'
  workflow_dispatch:

permissions:
  contents: read

jobs:
  build:
    runs-on: ubuntu-latest
    timeout-minutes: 360
    steps:
$setupSteps
      - name: Clone matching private source branch
        env:
          GH_TOKEN: `${{ secrets.COMPILER_PAT }}
        shell: bash
        run: |
          set -euo pipefail
          gh repo clone "`$GITHUB_REPOSITORY_OWNER/github_codespaces_compile" source -- --depth=1 --single-branch --branch "`$GITHUB_REF_NAME"
      - name: Execute source script
        working-directory: source
        shell: bash
        run: |
          set -euo pipefail
          chmod +x -- '$scriptRelative' 'tools/foundations/build_project.sh'
          './$scriptRelative'
"@
        Set-Utf8File $workflowPath $workflow

        $specifications.Add([pscustomobject][ordered]@{
            foundation = $Foundation
            key = $key
            project = $name
            language = $language
            repository = $repository
            branch = $branch
            version = $version
            checkout_ref = [string]$versionSpec.Ref
            source_script = $scriptRelative
            workflow = $workflowFile
            validation = 'pending'
        })
    }
}

$manifestDirectory = Join-Path $SourceRepo 'catalogs\foundations\coverage'
New-Item -ItemType Directory -Force -Path $manifestDirectory | Out-Null
$manifestPath = Join-Path $manifestDirectory "$Foundation-linux.json"
$specifications |
    Sort-Object branch |
    ConvertTo-Json -Depth 8 |
    Set-Content -LiteralPath $manifestPath -Encoding utf8NoBOM

[pscustomobject]@{
    foundation = $Foundation
    projects = $projects.Count
    build_targets = $specifications.Count
    latest_targets = @($specifications | Where-Object version -eq latest).Count
    stable_targets = @($specifications | Where-Object version -ne latest).Count
    manifest = $manifestPath
} | ConvertTo-Json
