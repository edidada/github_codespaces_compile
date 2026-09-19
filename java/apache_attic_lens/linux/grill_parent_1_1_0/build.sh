#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Lens'
export PROJECT_REPOSITORY='https://github.com/apache/lens.git'
export PROJECT_VERSION='grill_parent_1_1_0'
export PROJECT_REF='grill-parent-1.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
