#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='openRuyi'
export PROJECT_REPOSITORY='https://github.com/openRuyi-Project/openRuyi.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 该仓库是发行版的 SPECS 包描述集合，没有单一构建系统；
# 用 rpm 工具链逐个解析全部 spec，作为仓库级构建校验。
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y rpm && for s in SPECS/*/*.spec; do rpmspec -q --qf "%{NAME}\n" "$s" > /dev/null; done && echo "parsed $(ls SPECS/*/*.spec | wc -l) spec files"'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"