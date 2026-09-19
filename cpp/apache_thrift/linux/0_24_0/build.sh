#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Thrift'
export PROJECT_REPOSITORY='https://github.com/apache/thrift.git'
export PROJECT_VERSION='0_24_0'
export PROJECT_REF='v0.24.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
