#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Parquet'
export PROJECT_REPOSITORY='https://github.com/apache/parquet-java.git'
export PROJECT_VERSION='apache_parquet_1_18_1'
export PROJECT_REF='apache-parquet-1.18.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
