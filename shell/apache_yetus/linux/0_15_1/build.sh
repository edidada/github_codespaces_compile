#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Yetus'
export PROJECT_REPOSITORY='https://github.com/apache/yetus.git'
export PROJECT_VERSION='0_15_1'
export PROJECT_REF='rel/0.15.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
