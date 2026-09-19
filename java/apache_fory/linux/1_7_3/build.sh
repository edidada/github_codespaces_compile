#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Fory'
export PROJECT_REPOSITORY='https://github.com/apache/fory.git'
export PROJECT_VERSION='1_7_3'
export PROJECT_REF='v1.7.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
