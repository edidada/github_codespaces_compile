#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Devlake'
export PROJECT_REPOSITORY='https://github.com/apache/devlake.git'
export PROJECT_VERSION='20250513'
export PROJECT_REF='v20250513'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
