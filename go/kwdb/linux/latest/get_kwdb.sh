#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='KWDB'
export PROJECT_REPOSITORY='https://gitee.com/kwdb/kwdb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# KWDB 的 Makefile 与 CMakeLists 都会校验源码必须真实位于 <GOPATH>/src/gitee.com/kwbasedb，
# 符号链接会被 realpath 解析后判为不合规，所以把工作树整体复制到该布局再编译。
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y build-essential cmake protobuf-compiler libprotobuf-dev libssl-dev bison flex libncurses-dev && export GOPATH=/tmp/gopath && mkdir -p "$GOPATH/src/gitee.com" && cp -a "$PWD" "$GOPATH/src/gitee.com/kwbasedb" && cd "$GOPATH/src/gitee.com/kwbasedb" && git submodule update --init --recursive --depth=1 && go version && make build'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"