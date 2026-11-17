#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Rat'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/creadur/rat/trunk/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

if [ -z "${JAVA_HOME_8_X64:-}" ]; then
  J8DIR="$(ls -d /opt/hostedtoolcache/Java_Temurin-Hotspot_jdk/8*/x64 2>/dev/null | sort -V | tail -1 || true)"
  if [ -z "$J8DIR" ]; then
    J8DIR="$RUNNER_TEMP/jdk8"; mkdir -p "$J8DIR"
    curl -fsSL "https://api.adoptium.net/v3/binary/latest/8/ga/linux/x64/jdk/hotspot/normal/eclipse" -o "$J8DIR/jdk8.tar.gz"
    tar -xzf "$J8DIR/jdk8.tar.gz" -C "$J8DIR" --strip-components=1
  fi
  export JAVA_HOME_8_X64="$J8DIR"
fi
export JAVA_HOME="$JAVA_HOME_8_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='find . -name pom.xml -exec sed -i -E -e "s#(<source>)(1\.[0-9]|1\.3|5|6|7)(</source>)#\18\3#g" -e "s#(<target>)(1\.[0-9]|1\.3|5|6|7)(</target>)#\18\3#g" -e "s#(<maven\.compiler\.source>)(1\.[0-9]|1\.3|5|6|7)(</maven\.compiler\.source>)#\18\3#g" -e "s#(<maven\.compiler\.target>)(1\.[0-9]|1\.3|5|6|7)(</maven\.compiler\.target>)#\18\3#g" {} + && mvn -B -ntp -DskipTests -DskipITs package'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
