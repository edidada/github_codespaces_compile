#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Fluo'
export PROJECT_REPOSITORY='https://github.com/apache/accumulo-fluo.git'
export PROJECT_VERSION='fluo_parent_3'
export PROJECT_REF='rel/fluo-parent-3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
