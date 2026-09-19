#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Cordova'
export PROJECT_REPOSITORY='https://github.com/apache/cordova.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
