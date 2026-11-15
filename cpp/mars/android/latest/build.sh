#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Tencent Mars'
export PROJECT_REPOSITORY='https://github.com/Tencent/mars.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Mars publishes Android JNI artifacts through its Gradle module; this builds
# the release variant, including its native comm, xlog, STN and SDT code.
export PROJECT_BUILD_COMMAND='./gradlew :mars:assembleRelease'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
