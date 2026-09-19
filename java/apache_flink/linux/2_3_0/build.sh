#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Flink'
export PROJECT_REPOSITORY='https://github.com/apache/flink.git'
export PROJECT_VERSION='2_3_0'
export PROJECT_REF='release-2.3.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
