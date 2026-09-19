#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Statistics'
export PROJECT_REPOSITORY='https://github.com/apache/commons-statistics.git'
export PROJECT_VERSION='1_3'
export PROJECT_REF='rel/commons-statistics-1.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
