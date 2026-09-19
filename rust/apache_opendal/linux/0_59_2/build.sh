#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OpenDAL'
export PROJECT_REPOSITORY='https://github.com/apache/opendal.git'
export PROJECT_VERSION='0_59_2'
export PROJECT_REF='v0.59.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
