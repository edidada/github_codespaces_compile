#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Turbine'
export PROJECT_REPOSITORY='https://github.com/apache/turbine-core.git'
export PROJECT_VERSION='turbine_5_1'
export PROJECT_REF='turbine-5.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
