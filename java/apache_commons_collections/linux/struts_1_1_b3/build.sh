#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Collections'
export PROJECT_REPOSITORY='https://github.com/apache/commons-collections.git'
export PROJECT_VERSION='struts_1_1_b3'
export PROJECT_REF='struts-1.1-B3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
