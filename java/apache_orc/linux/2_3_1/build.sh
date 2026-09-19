#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ORC'
export PROJECT_REPOSITORY='https://github.com/apache/orc.git'
export PROJECT_VERSION='2_3_1'
export PROJECT_REF='v2.3.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
