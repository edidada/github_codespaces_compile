#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache PLC4X'
export PROJECT_REPOSITORY='https://github.com/apache/plc4x.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
