#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Hudi'
export PROJECT_REPOSITORY='https://github.com/apache/hudi.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_17_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='mvn -B -ntp -DskipTests -DskipITs -Pspark3.5 package'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
