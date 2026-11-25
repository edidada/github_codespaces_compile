#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Anolisa'
export PROJECT_REPOSITORY='https://github.com/alibaba/anolisa.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"