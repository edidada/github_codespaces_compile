#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Dolphinscheduler'
export PROJECT_REPOSITORY='https://github.com/apache/dolphinscheduler.git'
export PROJECT_VERSION='3_4_3'
export PROJECT_REF='3.4.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
