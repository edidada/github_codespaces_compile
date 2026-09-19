#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Drill'
export PROJECT_REPOSITORY='https://github.com/apache/drill.git'
export PROJECT_VERSION='drill_1_22_0'
export PROJECT_REF='drill-1.22.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
