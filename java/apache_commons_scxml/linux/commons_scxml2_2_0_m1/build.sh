#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons SCXML'
export PROJECT_REPOSITORY='https://github.com/apache/commons-scxml.git'
export PROJECT_VERSION='commons_scxml2_2_0_m1'
export PROJECT_REF='commons-scxml2-2.0-M1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
