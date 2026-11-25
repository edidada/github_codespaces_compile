#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='rvclaw'
export PROJECT_REPOSITORY='https://gitee.com/eulixos/rvclaw.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"