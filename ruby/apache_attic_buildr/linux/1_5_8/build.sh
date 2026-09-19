#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Buildr'
export PROJECT_REPOSITORY='https://github.com/apache/buildr.git'
export PROJECT_VERSION='1_5_8'
export PROJECT_REF='1.5.8'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
