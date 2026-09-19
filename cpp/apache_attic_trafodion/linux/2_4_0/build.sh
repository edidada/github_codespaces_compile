#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Trafodion'
export PROJECT_REPOSITORY='https://github.com/apache/trafodion.git'
export PROJECT_VERSION='2_4_0'
export PROJECT_REF='rel/2.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
