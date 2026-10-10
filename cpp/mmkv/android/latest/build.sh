#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Tencent MMKV'
export PROJECT_REPOSITORY='https://github.com/Tencent/MMKV.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# The Android module builds MMKV's mmap-backed C++ core and JNI bridge through
# the project's supported Gradle release task.
export PROJECT_BUILD_COMMAND='cd Android/MMKV && ./gradlew :mmkv:assembleRelease'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
