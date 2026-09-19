#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Numbers'
export PROJECT_REPOSITORY='https://github.com/apache/commons-numbers.git'
export PROJECT_VERSION='commons_numbers_1_3'
export PROJECT_REF='rel/commons-numbers-1.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
