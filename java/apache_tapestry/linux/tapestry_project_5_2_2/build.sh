#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tapestry'
export PROJECT_REPOSITORY='https://github.com/apache/tapestry-5.git'
export PROJECT_VERSION='tapestry_project_5_2_2'
export PROJECT_REF='tapestry-project-5.2.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
