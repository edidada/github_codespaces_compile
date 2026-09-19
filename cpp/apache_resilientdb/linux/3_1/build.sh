#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Resilientdb'
export PROJECT_REPOSITORY='https://github.com/apache/incubator-resilientdb.git'
export PROJECT_VERSION='3_1'
export PROJECT_REF='v3.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
