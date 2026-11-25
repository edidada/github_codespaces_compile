#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='KWDB'
export PROJECT_REPOSITORY='https://gitee.com/kwdb/kwdb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# KWDB = CockroachDB 派生的 Go 主库（GO111MODULE=off + vendor 子模块）+ C++ 时序引擎（CMake），
# 三个子模块（kw-vendor / kw-cdeps / kw-third_party）必须先拉全才能编译。
export PROJECT_BUILD_COMMAND='git submodule update --init --recursive --depth=1 && sudo apt-get update && sudo apt-get install -y build-essential cmake protobuf-compiler libprotobuf-dev libssl-dev bison flex libncurses-dev && go version && make build'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"