#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Kvrocks'
export PROJECT_REPOSITORY='https://github.com/apache/kvrocks.git'
export PROJECT_VERSION='2_16_0'
export PROJECT_REF='v2.16.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
