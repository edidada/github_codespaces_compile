#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Hive'
export PROJECT_REPOSITORY='https://github.com/apache/hive.git'
export PROJECT_VERSION='latest'
export PROJECT_REF='rel/release-4.0.1'

export JAVA_HOME="$JAVA_HOME_8_X64"
export PATH="$JAVA_HOME/bin:$PATH"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
