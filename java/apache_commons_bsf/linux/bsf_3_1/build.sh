#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons BSF'
export PROJECT_REPOSITORY='https://github.com/apache/commons-bsf.git'
export PROJECT_VERSION='bsf_3_1'
export PROJECT_REF='bsf-3.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
