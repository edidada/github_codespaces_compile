#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache MRUnit'
export PROJECT_REPOSITORY='https://github.com/apache/mrunit.git'
export PROJECT_VERSION='1_1_0'
export PROJECT_REF='release-1.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
