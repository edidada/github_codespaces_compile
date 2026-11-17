#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache FOP'
export PROJECT_REPOSITORY='https://svn.apache.org/repos/asf/xmlgraphics/fop/tags/fop-2_8/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export JAVA_HOME="$JAVA_HOME_11_X64"
export PATH="$JAVA_HOME/bin:$PATH"
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
