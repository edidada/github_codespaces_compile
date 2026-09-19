#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tajo'
export PROJECT_REPOSITORY='https://github.com/apache/tajo.git'
export PROJECT_VERSION='0_11_0'
export PROJECT_REF='release-0.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
