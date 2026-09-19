#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Oozie'
export PROJECT_REPOSITORY='https://github.com/apache/oozie.git'
export PROJECT_VERSION='5_2_1'
export PROJECT_REF='release-5.2.1'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
