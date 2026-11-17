#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache XML Commons Resolver'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/xerces/xml-commons/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_8_X64"
export PATH="$JAVA_HOME/bin:$PATH"
export PROJECT_BUILD_COMMAND='sed -i "s/source=\"1\.[0-9]\"/source=\"1.8\"/g; s/source=\"[567]\"/source=\"1.8\"/g; s/target=\"1\.[0-9]\"/target=\"1.8\"/g; s/target=\"[567]\"/target=\"1.8\"/g" build.xml && ant'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
