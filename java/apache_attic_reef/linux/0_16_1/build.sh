#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache REEF'
export PROJECT_REPOSITORY='https://github.com/apache/reef.git'
export PROJECT_VERSION='0_16_1'
export PROJECT_REF='release-0.16.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
