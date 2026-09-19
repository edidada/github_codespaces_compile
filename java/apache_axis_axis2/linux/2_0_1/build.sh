#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Axis2'
export PROJECT_REPOSITORY='https://github.com/apache/axis-axis2-java-core.git'
export PROJECT_VERSION='2_0_1'
export PROJECT_REF='v2.0.1'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
