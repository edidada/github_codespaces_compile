#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Geode'
export PROJECT_REPOSITORY='https://github.com/apache/geode.git'
export PROJECT_VERSION='v2_0_2'
export PROJECT_REF='rel/v2.0.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
