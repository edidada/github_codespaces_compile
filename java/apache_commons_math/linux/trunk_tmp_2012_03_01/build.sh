#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Math'
export PROJECT_REPOSITORY='https://github.com/apache/commons-math.git'
export PROJECT_VERSION='trunk_tmp_2012_03_01'
export PROJECT_REF='trunk_tmp_2012-03-01'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
