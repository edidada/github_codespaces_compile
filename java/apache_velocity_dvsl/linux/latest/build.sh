#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Velocity DVSL'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/velocity/dvsl/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# SVN 干线的 parent POM org.apache.velocity:velocity-master:1-SNAPSHOT 已不存在，
# 就地手术：去掉死 parent（仅根 pom，子模块 parent 是本地 dvsl-parent 会自动解析）、
# 源码级别升到 1.8、老 groupId velocity 改为 org.apache.velocity。
export PROJECT_BUILD_COMMAND='sed -i -e "/<parent>/,/<\/parent>/d" pom.xml && find . -name pom.xml -exec sed -i -e "s|<source>1.5</source>|<source>1.8</source>|" -e "s|<target>1.5</target>|<target>1.8</target>|" -e "s|<groupId>velocity</groupId>|<groupId>org.apache.velocity</groupId>|" {} + && mvn -B -ntp -DskipTests -pl :velocity-dvsl-core,:velocity-dvsl-ant package'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
