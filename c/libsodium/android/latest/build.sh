#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='libsodium'
export PROJECT_REPOSITORY='https://github.com/jedisct1/libsodium.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Use the NDK's API-24 arm64 toolchain to build libsodium's static native
# library.  Its test binaries target Android and cannot run on this Linux host.
export PROJECT_BUILD_COMMAND=': "${ANDROID_NDK_HOME:?Android NDK is required}"; toolchain="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"; export PATH="$toolchain/bin:$PATH"; export CC=aarch64-linux-android24-clang; export CXX=aarch64-linux-android24-clang++; ./autogen.sh; ./configure --host=aarch64-linux-android --disable-shared --enable-static && make -j2'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
