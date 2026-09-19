#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Spark'
export PROJECT_REPOSITORY='https://github.com/apache/spark.git'
export PROJECT_VERSION='4_2_0'
export PROJECT_REF='v4.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
