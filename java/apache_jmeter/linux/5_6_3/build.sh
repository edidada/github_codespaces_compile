#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache JMeter'
export PROJECT_REPOSITORY='https://github.com/apache/jmeter.git'
export PROJECT_VERSION='5_6_3'
export PROJECT_REF='rel/v5.6.3'

export JAVA_HOME="$JAVA_HOME_17_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='./gradlew --no-daemon -PchecksumIgnore=true build -x test'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
