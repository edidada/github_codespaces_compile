#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Velocity Tools'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/velocity/tools/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
