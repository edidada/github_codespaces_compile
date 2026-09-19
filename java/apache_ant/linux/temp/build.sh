#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ant'
export PROJECT_REPOSITORY='https://github.com/apache/ant.git'
export PROJECT_VERSION='temp'
export PROJECT_REF='temp'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
