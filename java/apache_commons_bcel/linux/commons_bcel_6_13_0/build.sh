#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons BCEL'
export PROJECT_REPOSITORY='https://github.com/apache/commons-bcel.git'
export PROJECT_VERSION='commons_bcel_6_13_0'
export PROJECT_REF='rel/commons-bcel-6.13.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
