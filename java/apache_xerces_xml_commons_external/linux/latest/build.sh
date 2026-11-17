#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache XML Commons External'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/xerces/xml-commons/'
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
fiexport JAVA_HOME="$JAVA_HOME_8_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='sed -i "s/source=\"1\.[0-9]\"/source=\"1.8\"/g; s/source=\"[567]\"/source=\"1.8\"/g; s/target=\"1\.[0-9]\"/target=\"1.8\"/g; s/target=\"[567]\"/target=\"1.8\"/g" build.xml && ant'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
