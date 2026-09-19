#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OpenOffice'
export PROJECT_REPOSITORY='https://github.com/apache/openoffice.git'
export PROJECT_VERSION='aoo4121'
export PROJECT_REF='AOO4121'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
