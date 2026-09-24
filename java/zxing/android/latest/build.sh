#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='ZXing Android'
export PROJECT_REPOSITORY='https://github.com/zxing/zxing.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='mvn -B -ntp -Pbuild-android -DadditionalJOption=-Xdoclint:none package'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
