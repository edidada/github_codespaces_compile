#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Flume'
export PROJECT_REPOSITORY='https://github.com/apache/flume.git'
export PROJECT_VERSION='1_8_0'
export PROJECT_REF='release-1.8.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
