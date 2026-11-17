#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache FreeMarker'
export PROJECT_REPOSITORY='https://github.com/apache/freemarker.git'
export PROJECT_VERSION='2_3_35'
export PROJECT_REF='v2.3.35'

export JAVA_HOME="$JAVA_HOME_17_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='./gradlew --no-daemon -Pfreemarker.allowUnsignedReleaseBuild=true build -x test'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
