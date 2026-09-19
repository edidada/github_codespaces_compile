#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Streampark'
export PROJECT_REPOSITORY='https://github.com/apache/streampark.git'
export PROJECT_VERSION='2_1_7'
export PROJECT_REF='v2.1.7'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
