#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache GeaFlow'
export PROJECT_REPOSITORY='https://github.com/apache/geaflow.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 上游测试依赖外部服务与特定时区/进程环境（DateTimeUtilTest、ProcessUtilTest 等在 CI 上必失败），
# 这里执行 Maven 打包校验（编译 + 打包全部模块），跳过测试。
export PROJECT_BUILD_COMMAND='if [ -x ./mvnw ]; then ./mvnw -B -ntp -DskipTests package; else mvn -B -ntp -DskipTests package; fi'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"