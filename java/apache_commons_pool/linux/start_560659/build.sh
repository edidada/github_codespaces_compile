#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Pool'
export PROJECT_REPOSITORY='https://github.com/apache/commons-pool.git'
export PROJECT_VERSION='start_560659'
export PROJECT_REF='start@560659'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
