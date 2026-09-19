#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons RNG'
export PROJECT_REPOSITORY='https://github.com/apache/commons-rng.git'
export PROJECT_VERSION='1_7'
export PROJECT_REF='rel/commons-rng-1.7'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
