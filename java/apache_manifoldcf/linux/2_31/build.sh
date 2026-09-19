#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ManifoldCF'
export PROJECT_REPOSITORY='https://github.com/apache/manifoldcf.git'
export PROJECT_VERSION='2_31'
export PROJECT_REF='release-2.31'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
