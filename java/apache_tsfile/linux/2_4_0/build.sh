#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache TsFile'
export PROJECT_REPOSITORY='https://github.com/apache/tsfile.git'
export PROJECT_VERSION='2_4_0'
export PROJECT_REF='v2.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
