#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Storm'
export PROJECT_REPOSITORY='https://github.com/apache/storm.git'
export PROJECT_VERSION='3_1_0'
export PROJECT_REF='v3.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
