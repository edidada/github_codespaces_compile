#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Google glog'
export PROJECT_REPOSITORY='https://github.com/google/glog.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Build glog's Android static library using its supported CMake configuration.
export PROJECT_BUILD_COMMAND=': "${ANDROID_NDK_HOME:?Android NDK is required}"; cmake -S . -B build-android -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 -DCMAKE_BUILD_TYPE=Release -DWITH_GFLAGS=OFF -DBUILD_TESTING=OFF && cmake --build build-android --parallel 2'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
