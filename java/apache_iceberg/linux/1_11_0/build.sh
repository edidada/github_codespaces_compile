#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Iceberg'
export PROJECT_REPOSITORY='https://github.com/apache/iceberg.git'
export PROJECT_VERSION='1_11_0'
export PROJECT_REF='apache-iceberg-1.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
