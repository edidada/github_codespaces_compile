#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons IO'
export PROJECT_REPOSITORY='https://github.com/apache/commons-io.git'
export PROJECT_VERSION='commons_io_2_22_0'
export PROJECT_REF='rel/commons-io-2.22.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
