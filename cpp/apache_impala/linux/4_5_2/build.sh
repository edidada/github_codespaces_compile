#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Impala'
export PROJECT_REPOSITORY='https://github.com/apache/impala.git'
export PROJECT_VERSION='4_5_2'
export PROJECT_REF='4.5.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
