#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Sedona'
export PROJECT_REPOSITORY='https://github.com/apache/sedona.git'
export PROJECT_VERSION='sedona_1_9_1'
export PROJECT_REF='sedona-1.9.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
