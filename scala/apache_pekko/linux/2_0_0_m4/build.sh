#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Pekko'
export PROJECT_REPOSITORY='https://github.com/apache/pekko.git'
export PROJECT_VERSION='2_0_0_m4'
export PROJECT_REF='v2.0.0-M4'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
