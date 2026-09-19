#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ranger'
export PROJECT_REPOSITORY='https://github.com/apache/ranger.git'
export PROJECT_VERSION='ranger_2_9_0'
export PROJECT_REF='release-ranger-2.9.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
