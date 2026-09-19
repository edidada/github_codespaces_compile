#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache DataFusion'
export PROJECT_REPOSITORY='https://github.com/apache/datafusion.git'
export PROJECT_VERSION='python_0_4_0'
export PROJECT_REF='python-0.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
