#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Doris'
export PROJECT_REPOSITORY='https://github.com/apache/doris.git'
export PROJECT_VERSION='4_1_4'
export PROJECT_REF='4.1.4'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
