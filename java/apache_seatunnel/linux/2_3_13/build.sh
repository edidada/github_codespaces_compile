#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache SeaTunnel'
export PROJECT_REPOSITORY='https://github.com/apache/seatunnel.git'
export PROJECT_VERSION='2_3_13'
export PROJECT_REF='2.3.13'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
