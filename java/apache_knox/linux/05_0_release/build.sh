#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Knox'
export PROJECT_REPOSITORY='https://github.com/apache/knox.git'
export PROJECT_VERSION='05_0_release'
export PROJECT_REF='v05.0-release'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
