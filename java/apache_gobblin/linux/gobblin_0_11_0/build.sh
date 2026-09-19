#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Gobblin'
export PROJECT_REPOSITORY='https://github.com/apache/gobblin.git'
export PROJECT_VERSION='gobblin_0_11_0'
export PROJECT_REF='gobblin_0.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
