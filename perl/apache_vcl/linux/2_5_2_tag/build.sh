#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache VCL'
export PROJECT_REPOSITORY='https://github.com/apache/vcl.git'
export PROJECT_VERSION='2_5_2_tag'
export PROJECT_REF='release-2.5.2-tag'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
