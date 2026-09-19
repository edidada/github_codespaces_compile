#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache CXF'
export PROJECT_REPOSITORY='https://github.com/apache/cxf.git'
export PROJECT_VERSION='cxf_4_2_3'
export PROJECT_REF='cxf-4.2.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
