#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache rivet'
export PROJECT_REPOSITORY='https://github.com/apache/tcl-rivet.git'
export PROJECT_VERSION='rivet_3_2_0'
export PROJECT_REF='rivet-3.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
