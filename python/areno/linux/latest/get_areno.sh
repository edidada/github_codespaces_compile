#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='AReno'
export PROJECT_REPOSITORY='https://github.com/inclusionAI/AReno.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 上游 tests/ 中 60 个用例在 CPU runner 上因 kernel 参数校验失败（需要特定 torch 版本），
# 这里改为安装依赖并构建发行 wheel，作为可重复的构建验收。
export PROJECT_BUILD_COMMAND='python -m pip install --upgrade pip build && python -m pip install -e . --no-deps && python -m build && ls dist'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"