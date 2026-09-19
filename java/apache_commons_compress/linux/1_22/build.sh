#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Compress'
export PROJECT_REPOSITORY='https://github.com/apache/commons-compress.git'
export PROJECT_VERSION='1_22'
export PROJECT_REF='rel/1.22'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
