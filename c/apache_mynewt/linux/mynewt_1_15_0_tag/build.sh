#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Mynewt'
export PROJECT_REPOSITORY='https://github.com/apache/mynewt-core.git'
export PROJECT_VERSION='mynewt_1_15_0_tag'
export PROJECT_REF='mynewt_1_15_0_tag'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
