#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache YuniKorn'
export PROJECT_REPOSITORY='https://github.com/apache/yunikorn-core.git'
export PROJECT_VERSION='1_9_0'
export PROJECT_REF='v1.9.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
