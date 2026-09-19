#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4cxx'
export PROJECT_REPOSITORY='https://github.com/apache/logging-log4cxx.git'
export PROJECT_VERSION='0_11_0'
export PROJECT_REF='v0.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
