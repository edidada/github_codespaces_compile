#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache MyFaces'
export PROJECT_REPOSITORY='https://github.com/apache/myfaces.git'
export PROJECT_VERSION='myfaces_core_project_2_1_6'
export PROJECT_REF='myfaces-core-project-2.1.6'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
