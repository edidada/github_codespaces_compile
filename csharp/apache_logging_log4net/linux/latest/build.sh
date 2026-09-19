#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4net'
export PROJECT_REPOSITORY='https://github.com/apache/logging-log4net.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='dotnet build ./src/log4net.sln && dotnet test ./src/log4net.sln --no-build'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
