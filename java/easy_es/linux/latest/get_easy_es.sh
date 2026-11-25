#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Easy-Es'
export PROJECT_REPOSITORY='https://github.com/dromara/easy-es.git'
export PROJECT_VERSION='latest'
# 上游默认分支 main 内部不一致（源码仍引用已移除的 fastjson/RestHighLevelClient），
# 3.0.x 发布线位于 master 分支，改用该分支跟踪。
export PROJECT_REF='master'
# 单元测试需要真实 Elasticsearch；此处做 Maven 打包校验。
export PROJECT_BUILD_COMMAND='if [ -x ./mvnw ]; then ./mvnw -B -ntp -DskipTests package; else mvn -B -ntp -DskipTests package; fi'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"