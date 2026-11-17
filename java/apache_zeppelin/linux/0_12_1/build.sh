#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Zeppelin'
export PROJECT_REPOSITORY='https://github.com/apache/zeppelin.git'
export PROJECT_VERSION='0_12_1'
export PROJECT_REF='v0.12.1'

export JAVA_HOME="$JAVA_HOME_17_X64"
export PATH="$JAVA_HOME/bin:$PATH"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
