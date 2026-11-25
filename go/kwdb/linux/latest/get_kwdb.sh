#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='KWDB'
export PROJECT_REPOSITORY='https://gitee.com/kwdb/kwdb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# KWDB 的 Makefile 强制 GOPATH 布局（源码必须位于 <GOPATH>/src/gitee.com/kwbasedb），
# 因此克隆后先建符号链接把工作目录挂到 GOPATH 下，再拉子模块并编译。
export PROJECT_BUILD_COMMAND='git submodule update --init --recursive --depth=1 && sudo apt-get update && sudo apt-get install -y build-essential cmake protobuf-compiler libprotobuf-dev libssl-dev bison flex libncurses-dev && export GOPATH=/tmp/gopath && mkdir -p "$GOPATH/src/gitee.com" && ln -sfn "$PWD" "$GOPATH/src/gitee.com/kwbasedb" && cd "$GOPATH/src/gitee.com/kwbasedb" && go version && make build'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"