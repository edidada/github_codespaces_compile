#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Nuttx'
export PROJECT_REPOSITORY='https://github.com/apache/nuttx.git'
export PROJECT_VERSION='nuttx_13_0_1'
export PROJECT_REF='nuttx-13.0.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
