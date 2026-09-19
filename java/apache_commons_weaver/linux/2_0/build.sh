#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Weaver'
export PROJECT_REPOSITORY='https://github.com/apache/commons-weaver.git'
export PROJECT_VERSION='2_0'
export PROJECT_REF='rel/2.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
