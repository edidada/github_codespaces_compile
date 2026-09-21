#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Aeron'
export PROJECT_REPOSITORY='https://github.com/aeron-io/aeron.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND="sed -i 's/^networkTimeout=.*/networkTimeout=60000/' gradle/wrapper/gradle-wrapper.properties && ./gradlew --no-daemon test"

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
