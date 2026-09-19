#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Groovy'
export PROJECT_REPOSITORY='https://github.com/apache/groovy.git'
export PROJECT_VERSION='groovy_6_0_0'
export PROJECT_REF='GROOVY_6_0_0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
