#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='BoringSSL'
export PROJECT_REPOSITORY='https://boringssl.googlesource.com/boringssl'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Cross-compile the SSL and crypto libraries for Android arm64 through CMake.
# Upstream tests are target executables and are therefore not run on the host.
export PROJECT_BUILD_COMMAND=': "${ANDROID_NDK_HOME:?Android NDK is required}"; cmake -S . -B build-android -DCMAKE_TOOLCHAIN_FILE="$ANDROID_NDK_HOME/build/cmake/android.toolchain.cmake" -DANDROID_ABI=arm64-v8a -DANDROID_PLATFORM=android-24 -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && cmake --build build-android --parallel 2'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
