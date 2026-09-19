#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Druid'
export PROJECT_REPOSITORY='https://github.com/apache/druid.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
