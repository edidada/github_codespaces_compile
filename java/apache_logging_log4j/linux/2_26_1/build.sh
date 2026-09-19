#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Log4j'
export PROJECT_REPOSITORY='https://github.com/apache/logging-log4j2.git'
export PROJECT_VERSION='2_26_1'
export PROJECT_REF='rel/2.26.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
