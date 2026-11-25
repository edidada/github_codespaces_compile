#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Mooncake'
export PROJECT_REPOSITORY='https://github.com/kvcache-ai/Mooncake.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"