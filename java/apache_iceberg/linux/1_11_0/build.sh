#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Iceberg'
export PROJECT_REPOSITORY='https://github.com/apache/iceberg.git'
export PROJECT_VERSION='1_11_0'
export PROJECT_REF='apache-iceberg-1.11.0'

export JAVA_HOME="$JAVA_HOME_21_X64"
export PATH="$JAVA_HOME/bin:$PATH"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
