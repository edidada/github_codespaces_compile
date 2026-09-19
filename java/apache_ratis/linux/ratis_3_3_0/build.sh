#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ratis'
export PROJECT_REPOSITORY='https://github.com/apache/ratis.git'
export PROJECT_VERSION='ratis_3_3_0'
export PROJECT_REF='ratis-3.3.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
