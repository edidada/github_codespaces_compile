#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Agrona.NET'
export PROJECT_REPOSITORY='https://github.com/AdaptiveConsulting/Aeron.NET.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_ROOT='src'
export PROJECT_BUILD_COMMAND='dotnet test Adaptive.Agrona.Tests/Adaptive.Agrona.Tests.csproj --configuration Release'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
