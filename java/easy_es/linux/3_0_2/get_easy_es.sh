#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Easy-Es'
export PROJECT_REPOSITORY='https://github.com/dromara/easy-es.git'
export PROJECT_VERSION='3_0_2'
# 3.0.x 发布线在 master；默认分支 main 内部不一致（源码引用已移除的 fastjson/RestHighLevelClient）。
export PROJECT_REF='master'
# 单元测试依赖真实 Elasticsearch 实例，这里做 Maven 打包校验。
export PROJECT_BUILD_COMMAND='if [ -x ./mvnw ]; then ./mvnw -B -ntp -DskipTests package; else mvn -B -ntp -DskipTests package; fi'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"