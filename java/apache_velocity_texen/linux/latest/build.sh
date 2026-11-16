#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Texen'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/velocity/texen/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# SVN 干线的 parent POM org.apache.velocity:velocity-master:1-SNAPSHOT 已不存在，
# 就地手术：去掉死 parent、源码级别升到 1.8、老 groupId velocity 改为 org.apache.velocity。
export PROJECT_BUILD_COMMAND='sed -i -e "/<parent>/,/<\/parent>/d" -e "s|<source>1.4</source>|<source>1.8</source>|" -e "s|<target>1.4</target>|<target>1.8</target>|" -e "s|<groupId>velocity</groupId>|<groupId>org.apache.velocity</groupId>|" pom.xml && mvn -B -ntp -DskipTests package'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
