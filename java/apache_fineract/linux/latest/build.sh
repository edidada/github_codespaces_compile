#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Fineract'
export PROJECT_REPOSITORY='https://github.com/apache/fineract.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='git fetch --unshallow 2>/dev/null || true ; git fetch --tags --force 2>/dev/null || true ; ./gradlew --no-daemon assemble'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
