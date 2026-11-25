#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Sa-Token'
export PROJECT_REPOSITORY='https://gitee.com/dromara/sa-token.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"