#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Traffic Control'
export PROJECT_REPOSITORY='https://github.com/apache/trafficcontrol.git'
export PROJECT_VERSION='8_0_2'
export PROJECT_REF='v8.0.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
