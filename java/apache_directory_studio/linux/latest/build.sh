#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Directory Studio'
export PROJECT_REPOSITORY='https://github.com/apache/directory-studio.git'
export PROJECT_VERSION='2.0.0.v20210717-M17'
export PROJECT_REF='2.0.0.v20210717-M17'

export JAVA_HOME="$JAVA_HOME_11_X64"
export PATH="$JAVA_HOME/bin:$PATH"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
