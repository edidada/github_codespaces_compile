#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache DeltaSpike'
export PROJECT_REPOSITORY='https://github.com/apache/deltaspike.git'
export PROJECT_VERSION='deltaspike_root_1_3_0'
export PROJECT_REF='deltaspike-root-1.3.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
