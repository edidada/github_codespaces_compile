#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Net'
export PROJECT_REPOSITORY='https://github.com/apache/commons-net.git'
export PROJECT_VERSION='1_3_8'
export PROJECT_REF='v1-3-8'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
