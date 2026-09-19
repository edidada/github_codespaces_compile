#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Hudi'
export PROJECT_REPOSITORY='https://github.com/apache/hudi.git'
export PROJECT_VERSION='1_2_0'
export PROJECT_REF='release-1.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
