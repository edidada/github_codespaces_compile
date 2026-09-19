#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Buildstream'
export PROJECT_REPOSITORY='https://github.com/apache/buildstream.git'
export PROJECT_VERSION='bst_1_4_branchpoint'
export PROJECT_REF='bst-1.4-branchpoint'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
