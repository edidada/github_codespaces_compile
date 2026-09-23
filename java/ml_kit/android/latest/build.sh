#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Google ML Kit Android samples'
export PROJECT_REPOSITORY='https://github.com/googlesamples/mlkit.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_ROOT='android'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
