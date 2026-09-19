#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache VXQuery'
export PROJECT_REPOSITORY='https://github.com/apache/vxquery.git'
export PROJECT_VERSION='xquery_0_1'
export PROJECT_REF='vxquery-0.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
