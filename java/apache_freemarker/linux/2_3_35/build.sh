#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache FreeMarker'
export PROJECT_REPOSITORY='https://github.com/apache/freemarker.git'
export PROJECT_VERSION='2_3_35'
export PROJECT_REF='v2.3.35'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
