#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons JCS'
export PROJECT_REPOSITORY='https://github.com/apache/commons-jcs.git'
export PROJECT_VERSION='3_2_1'
export PROJECT_REF='rel/commons-jcs3-3.2.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
