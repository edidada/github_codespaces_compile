#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='KubeEdge Sedna'
export PROJECT_REPOSITORY='https://github.com/kubeedge/sedna.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# test/e2e 需要真实 Kubernetes 集群，托管 runner 上无法启动；其余包正常构建与测试。
export PROJECT_BUILD_COMMAND='go build ./... && go test $(go list ./... | grep -v "/test/e2e")'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"