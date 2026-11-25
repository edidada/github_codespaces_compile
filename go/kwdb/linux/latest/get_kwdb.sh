#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='KWDB'
export PROJECT_REPOSITORY='https://gitee.com/kwdb/kwdb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 1) Makefile 与 CMakeLists 都校验源码必须真实位于 <GOPATH>/src/gitee.com/kwbasedb，符号链接会被 realpath 判不合规，故整体复制；
# 2) 内置 third_party/zstd 的 CMakeLists 使用旧版 cmake_minimum_required，CMake 4.x 直接拒绝配置，
#    因此装一套 CMake 3.x 放到 PATH 前面。
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y build-essential protobuf-compiler libprotobuf-dev libssl-dev bison flex libncurses-dev && python3 -m pip install --upgrade "cmake<4" && export PATH="$HOME/.local/bin:$PATH" && cmake --version && export GOPATH=/tmp/gopath && mkdir -p "$GOPATH/src/gitee.com" && cp -a "$PWD" "$GOPATH/src/gitee.com/kwbasedb" && cd "$GOPATH/src/gitee.com/kwbasedb" && git submodule update --init --recursive --depth=1 && go version && make build'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"