#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Streampipes'
export PROJECT_REPOSITORY='https://github.com/apache/streampipes.git'
export PROJECT_VERSION='0_98_0'
export PROJECT_REF='release/0.98.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
