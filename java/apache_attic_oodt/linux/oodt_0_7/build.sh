#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OODT'
export PROJECT_REPOSITORY='https://github.com/apache/oodt.git'
export PROJECT_VERSION='oodt_0_7'
export PROJECT_REF='oodt-0.7'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
