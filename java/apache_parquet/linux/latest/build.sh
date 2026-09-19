#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Parquet'
export PROJECT_REPOSITORY='https://github.com/apache/parquet-java.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
