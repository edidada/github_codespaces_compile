#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4net'
export PROJECT_REPOSITORY='https://github.com/apache/logging-log4net.git'
export PROJECT_VERSION='3_4_0'
export PROJECT_REF='rel/3.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
