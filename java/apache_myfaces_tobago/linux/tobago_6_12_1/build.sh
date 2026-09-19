#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tobago'
export PROJECT_REPOSITORY='https://github.com/apache/myfaces-tobago.git'
export PROJECT_VERSION='tobago_6_12_1'
export PROJECT_REF='tobago-6.12.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
