#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='LevelDB'
export PROJECT_REPOSITORY='https://github.com/google/leveldb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Cross-compile the actual LevelDB C++ library for Android arm64.  Tests and
# benchmarks are host binaries, so they are intentionally disabled here.
export PROJECT_BUILD_COMMAND=': "${ANDROID_NDK_HOME:?Android NDK is required}"; cmake -S . -B build-android -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 -DCMAKE_BUILD_TYPE=Release -DLEVELDB_BUILD_TESTS=OFF -DLEVELDB_BUILD_BENCHMARKS=OFF && cmake --build build-android --parallel 2'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
