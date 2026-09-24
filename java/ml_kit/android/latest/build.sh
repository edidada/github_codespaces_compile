#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Google ML Kit Android samples'
export PROJECT_REPOSITORY='https://github.com/googlesamples/mlkit.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_ROOT='android/vision-quickstart'
export PROJECT_BUILD_COMMAND="sed -i 's/ -XX:MaxPermSize=1024m//' gradle.properties && ./gradlew --no-daemon build"

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
