#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Auron'
export PROJECT_REPOSITORY='https://github.com/apache/auron.git'
export PROJECT_VERSION='8_0_0'
export PROJECT_REF='v8.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
