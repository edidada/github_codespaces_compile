#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Logging'
export PROJECT_REPOSITORY='https://github.com/apache/commons-logging.git'
export PROJECT_VERSION='commons_logging_1_4_0'
export PROJECT_REF='rel/commons-logging-1.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
