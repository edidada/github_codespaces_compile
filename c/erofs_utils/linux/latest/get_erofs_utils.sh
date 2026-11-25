#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='EROFS Utils'
export PROJECT_REPOSITORY='https://github.com/erofs/erofs-utils.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"