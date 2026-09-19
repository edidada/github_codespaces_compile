#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache CarbonData'
export PROJECT_REPOSITORY='https://github.com/apache/carbondata.git'
export PROJECT_VERSION='carbondata_parent_2_3_2'
export PROJECT_REF='carbondata-parent-2.3.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
