#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache CarbonData'
export PROJECT_REPOSITORY='https://github.com/apache/carbondata.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='sudo apt-get update -qq && sudo apt-get install -y -qq thrift-compiler && mvn -B -ntp -DskipTests -DskipITs package'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
