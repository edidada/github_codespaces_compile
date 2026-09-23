#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Metabase'
export PROJECT_REPOSITORY='https://github.com/metabase/metabase.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='./bin/build.sh'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
