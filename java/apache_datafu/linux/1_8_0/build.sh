#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache DataFu'
export PROJECT_REPOSITORY='https://github.com/apache/datafu.git'
export PROJECT_VERSION='1_8_0'
export PROJECT_REF='v1.8.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
