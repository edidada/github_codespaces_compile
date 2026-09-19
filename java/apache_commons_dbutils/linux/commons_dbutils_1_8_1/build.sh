#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons DbUtils'
export PROJECT_REPOSITORY='https://github.com/apache/commons-dbutils.git'
export PROJECT_VERSION='commons_dbutils_1_8_1'
export PROJECT_REF='rel/commons-dbutils-1.8.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
