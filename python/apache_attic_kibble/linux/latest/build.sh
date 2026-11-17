#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Kibble'
export PROJECT_REPOSITORY='https://github.com/apache/kibble-1.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='python -m pip install --upgrade pip build wheel && python -m pip install "setuptools<81" pyyaml && python -m build --no-isolation --wheel'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
