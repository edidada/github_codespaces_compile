#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache SkyWalking BanyanDB'
export PROJECT_REPOSITORY='https://github.com/apache/skywalking-banyandb.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# api/proto 下的 bydbql、fodc 等代码由 `make generate` 生成，干净克隆缺失；
# 这里先生成再构建，并跳过依赖 Docker 的 test/integration。
export PROJECT_BUILD_COMMAND='make generate && go build ./... && go test $(go list ./... | grep -v -e "/test/integration" -e "/test/e2e")'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"