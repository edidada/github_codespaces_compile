#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Rat'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/creadur/rat/trunk/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_8_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='find . -name pom.xml -exec sed -i -E "s#(<source>)(1\.[0-9]|1\.3|5|6|7)(</source>)#\18\3#g" -E "s#(<target>)(1\.[0-9]|1\.3|5|6|7)(</target>)#\18\3#g" -E "s#(<maven\.compiler\.source>)(1\.[0-9]|1\.3|5|6|7)(</maven\.compiler\.source>)#\18\3#g" -E "s#(<maven\.compiler\.target>)(1\.[0-9]|1\.3|5|6|7)(</maven\.compiler\.target>)#\18\3#g" {} + && mvn -B -ntp -DskipTests -DskipITs package'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
