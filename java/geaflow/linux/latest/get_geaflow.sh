#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache GeaFlow'
export PROJECT_REPOSITORY='https://github.com/apache/geaflow.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# geaflow-assembly 的打包步骤在 2 核 runner 上生成发行包时失败（MojoExecutionException），
# 上游测试又依赖外部环境与时区；这里执行全模块 Maven 编译校验。
export PROJECT_BUILD_COMMAND='if [ -x ./mvnw ]; then ./mvnw -B -ntp -DskipTests compile; else mvn -B -ntp -DskipTests compile; fi'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"