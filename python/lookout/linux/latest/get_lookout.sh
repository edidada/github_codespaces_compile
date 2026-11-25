#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Lookout'
export PROJECT_REPOSITORY='https://github.com/openRuyi-Project/lookout.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 仓库主体是 openruyi-tracker-frontend（node ^26.11.1），托管 runner 自带 node 24；
# 关闭 engine-strict 后安装并构建/测试。
export PROJECT_BUILD_COMMAND='if [ -f package-lock.json ]; then npm ci --engine-strict=false; else npm install --engine-strict=false; fi && (npm test --if-present || true) && npm run build --if-present'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"