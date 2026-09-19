#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Empire-db'
export PROJECT_REPOSITORY='https://github.com/apache/empire-db.git'
export PROJECT_VERSION='empire_db_parent_2_5_1'
export PROJECT_REF='empire-db-parent-2.5.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
