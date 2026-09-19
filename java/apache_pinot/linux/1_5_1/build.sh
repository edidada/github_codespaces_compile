#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Pinot'
export PROJECT_REPOSITORY='https://github.com/apache/pinot.git'
export PROJECT_VERSION='1_5_1'
export PROJECT_REF='release-1.5.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
