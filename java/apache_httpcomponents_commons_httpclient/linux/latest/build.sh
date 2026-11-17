#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Commons HttpClient'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/httpcomponents/oac.hc3x/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='iconv -f ISO-8859-1 -t UTF-8 src/java/org/apache/commons/httpclient/HttpContentTooLargeException.java > /tmp/htle.java && mv /tmp/htle.java src/java/org/apache/commons/httpclient/HttpContentTooLargeException.java && ant'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
