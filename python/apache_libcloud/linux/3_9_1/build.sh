#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Libcloud'
export PROJECT_REPOSITORY='https://github.com/apache/libcloud.git'
export PROJECT_VERSION='3_9_1'
export PROJECT_REF='v3.9.1'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
