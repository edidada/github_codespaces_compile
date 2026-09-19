#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Flex'
export PROJECT_REPOSITORY='https://github.com/apache/flex-sdk.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='ant -Dbuild.noprompt=true modules'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
