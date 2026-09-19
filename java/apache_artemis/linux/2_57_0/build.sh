#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Artemis'
export PROJECT_REPOSITORY='https://github.com/apache/artemis.git'
export PROJECT_VERSION='2_57_0'
export PROJECT_REF='2.57.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
