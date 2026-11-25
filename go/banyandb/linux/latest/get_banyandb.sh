#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache SkyWalking BanyanDB'
export PROJECT_REPOSITORY='https://github.com/apache/skywalking-banyandb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 上游 pkg/flow、pkg/test/flow 的测试依赖 mockgen 生成的 mock（Makefile generate 目标），
# 干净克隆下这些包无法编译测试；此处构建全部包并跳过这两个包。
export PROJECT_BUILD_COMMAND='go build ./... && go test $(go list ./... | grep -v -e "banyandb/pkg/flow$" -e "banyandb/pkg/flow/" -e "banyandb/pkg/test/flow")'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"