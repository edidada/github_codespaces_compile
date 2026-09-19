#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Cayenne'
export PROJECT_REPOSITORY='https://github.com/apache/cayenne.git'
export PROJECT_VERSION='cayenne_parent_5_0_m2'
export PROJECT_REF='cayenne-parent-5.0-M2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
