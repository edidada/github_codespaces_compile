#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons JXPath'
export PROJECT_REPOSITORY='https://github.com/apache/commons-jxpath.git'
export PROJECT_VERSION='commons_jxpath_1_4_0'
export PROJECT_REF='rel/commons-jxpath-1.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
