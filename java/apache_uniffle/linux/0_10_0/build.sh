#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Uniffle'
export PROJECT_REPOSITORY='https://github.com/apache/uniffle.git'
export PROJECT_VERSION='0_10_0'
export PROJECT_REF='v0.10.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
