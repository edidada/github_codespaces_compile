#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons JCI'
export PROJECT_REPOSITORY='https://github.com/apache/commons-jci.git'
export PROJECT_VERSION='1_1'
export PROJECT_REF='1.1'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
