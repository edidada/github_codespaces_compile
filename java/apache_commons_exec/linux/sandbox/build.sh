#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Exec'
export PROJECT_REPOSITORY='https://github.com/apache/commons-exec.git'
export PROJECT_VERSION='sandbox'
export PROJECT_REF='sandbox'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
