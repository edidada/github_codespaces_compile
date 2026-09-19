#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Whimsy'
export PROJECT_REPOSITORY='https://github.com/apache/whimsy.git'
export PROJECT_VERSION='board_agenda'
export PROJECT_REF='board_agenda'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
