#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ECharts'
export PROJECT_REPOSITORY='https://github.com/apache/echarts.git'
export PROJECT_VERSION='6_1_0'
export PROJECT_REF='6.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
