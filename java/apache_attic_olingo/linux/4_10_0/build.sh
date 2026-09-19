#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Olingo'
export PROJECT_REPOSITORY='https://github.com/apache/olingo-odata4.git'
export PROJECT_VERSION='4_10_0'
export PROJECT_REF='4.10.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
