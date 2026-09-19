#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Kyuubi'
export PROJECT_REPOSITORY='https://github.com/apache/kyuubi.git'
export PROJECT_VERSION='1_12_0'
export PROJECT_REF='v1.12.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
