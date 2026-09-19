#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Retired: Apache .NET Ant Library'
export PROJECT_REPOSITORY='https://github.com/apache/ant-antlibs-dotnet.git'
export PROJECT_VERSION='1_1'
export PROJECT_REF='rel/1.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
