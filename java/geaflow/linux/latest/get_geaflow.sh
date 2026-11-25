#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache GeaFlow'
export PROJECT_REPOSITORY='https://github.com/apache/geaflow.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 上游 geaflow-assembly 的 git-commit-id-plugin 在浅克隆（--filter=blob:none）下无法初始化仓库格式；
# 上游测试依赖外部环境与时区，故此构建执行全模块编译并跳过该插件与测试。
export PROJECT_BUILD_COMMAND='if [ -x ./mvnw ]; then ./mvnw -B -ntp -DskipTests -Dmaven.gitcommitid.skip=true compile; else mvn -B -ntp -DskipTests -Dmaven.gitcommitid.skip=true compile; fi'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"