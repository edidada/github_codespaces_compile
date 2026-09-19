#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Wayang'
export PROJECT_REPOSITORY='https://github.com/apache/wayang.git'
export PROJECT_VERSION='wayang_1_1_1'
export PROJECT_REF='wayang-1.1.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
