#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache STeVe'
export PROJECT_REPOSITORY='https://github.com/apache/steve.git'
export PROJECT_VERSION='2'
export PROJECT_REF='v2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
