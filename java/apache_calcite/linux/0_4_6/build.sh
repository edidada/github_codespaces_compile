#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Calcite'
export PROJECT_REPOSITORY='https://github.com/apache/calcite.git'
export PROJECT_VERSION='0_4_6'
export PROJECT_REF='v0.4.6'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
