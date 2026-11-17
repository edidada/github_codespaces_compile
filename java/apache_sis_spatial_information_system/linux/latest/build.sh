#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Spatial Information System'
export PROJECT_REPOSITORY='https://github.com/apache/sis.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_17_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='find . -name build.gradle.kts -exec sed -i "s/options.release.set(22)/options.release.set(17)/" {} + && ./gradlew --no-daemon build -x test'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
