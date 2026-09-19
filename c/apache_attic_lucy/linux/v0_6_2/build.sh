#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Lucy'
export PROJECT_REPOSITORY='https://github.com/apache/lucy.git'
export PROJECT_VERSION='v0_6_2'
export PROJECT_REF='rel/v0.6.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
