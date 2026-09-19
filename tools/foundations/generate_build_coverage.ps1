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

foreach ($project in $projects) {
    if ($Foundation -eq 'apache') {
        $key = [string]$project.key
        $name = [string]$project.name
        $repository = [string]$project.primary_repository
        $languageValue = [string]$project.detected_language
        if (-not $languageValue) { $languageValue = [string]@($project.language)[0] }
        $product = "apache_$(ConvertTo-Slug $key)"
        # The branch version must describe the exact revision that is checked
        # out. projects.apache.org release labels do not always map 1:1 to a
        # Git tag, so use the verified non-prerelease tag for both.
        $stableVersion = [string]$project.stable_tag
        $stableRef = [string]$project.stable_tag
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

        $wrapper = @"
#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME=$(ConvertTo-BashLiteral $name)
export PROJECT_REPOSITORY=$(ConvertTo-BashLiteral $repository)
export PROJECT_VERSION=$(ConvertTo-BashLiteral $version)
export PROJECT_REF=$(ConvertTo-BashLiteral ([string]$versionSpec.Ref))
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
- Build policy: clone the requested revision and run the repository's native build and test system through `tools/foundations/build_project.sh`.

The branch and path follow `编程语言/软件名称/操作系统/版本`. A failing native build is kept visible in GitHub Actions and is repaired with project-specific prerequisites or commands rather than being reported as a pass.
"@
        Set-Utf8File $readmePath $readme

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
