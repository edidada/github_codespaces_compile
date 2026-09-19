#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache CloudStack'
export PROJECT_REPOSITORY='https://github.com/apache/cloudstack.git'
export PROJECT_VERSION='4_23_0_0'
export PROJECT_REF='4.23.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
