#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ozone'
export PROJECT_REPOSITORY='https://github.com/apache/ozone.git'
export PROJECT_VERSION='ozone_2_1_2'
export PROJECT_REF='ozone-2.1.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
