#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache IoTDB'
export PROJECT_REPOSITORY='https://github.com/apache/iotdb.git'
export PROJECT_VERSION='2_0_11'
export PROJECT_REF='v2.0.11'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
