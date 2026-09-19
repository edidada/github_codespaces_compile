#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache JDO'
export PROJECT_REPOSITORY='https://github.com/apache/db-jdo.git'
export PROJECT_VERSION='3_2_1'
export PROJECT_REF='v3.2.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
