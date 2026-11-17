#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Buildstream'
export PROJECT_REPOSITORY='https://github.com/apache/buildstream.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='git fetch --tags -f -q 2>/dev/null || true ; python -m pip install --upgrade pip build setuptools wheel && python -m pip install -e . && python -m build --wheel'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
