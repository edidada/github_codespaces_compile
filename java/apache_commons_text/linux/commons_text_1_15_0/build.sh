#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Text'
export PROJECT_REPOSITORY='https://github.com/apache/commons-text.git'
export PROJECT_VERSION='commons_text_1_15_0'
export PROJECT_REF='rel/commons-text-1.15.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
