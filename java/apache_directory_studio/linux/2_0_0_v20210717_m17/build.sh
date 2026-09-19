#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Directory Studio'
export PROJECT_REPOSITORY='https://github.com/apache/directory-studio.git'
export PROJECT_VERSION='2_0_0_v20210717_m17'
export PROJECT_REF='2.0.0.v20210717-M17'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
