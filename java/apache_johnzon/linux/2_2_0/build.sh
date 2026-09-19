#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Johnzon'
export PROJECT_REPOSITORY='https://github.com/apache/johnzon.git'
export PROJECT_VERSION='2_2_0'
export PROJECT_REF='v2.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
