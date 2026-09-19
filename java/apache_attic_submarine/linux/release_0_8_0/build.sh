#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Submarine'
export PROJECT_REPOSITORY='https://github.com/apache/submarine.git'
export PROJECT_VERSION='release_0_8_0'
export PROJECT_REF='rel/release-0.8.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
