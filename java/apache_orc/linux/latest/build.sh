#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ORC'
export PROJECT_REPOSITORY='https://github.com/apache/orc.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
