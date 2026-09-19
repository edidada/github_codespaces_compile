#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tika'
export PROJECT_REPOSITORY='https://github.com/apache/tika.git'
export PROJECT_VERSION='tika_1_3'
export PROJECT_REF='tika-1.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
