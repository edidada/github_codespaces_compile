#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Samza'
export PROJECT_REPOSITORY='https://github.com/apache/samza.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_11_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='./gradlew --no-daemon assemble'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
