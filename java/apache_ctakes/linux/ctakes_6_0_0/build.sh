#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache cTAKES'
export PROJECT_REPOSITORY='https://github.com/apache/ctakes.git'
export PROJECT_VERSION='ctakes_6_0_0'
export PROJECT_REF='ctakes-6.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
