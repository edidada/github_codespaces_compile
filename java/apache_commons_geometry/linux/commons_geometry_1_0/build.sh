#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Geometry'
export PROJECT_REPOSITORY='https://github.com/apache/commons-geometry.git'
export PROJECT_VERSION='commons_geometry_1_0'
export PROJECT_REF='rel/commons-geometry-1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
