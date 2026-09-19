#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Clerezza'
export PROJECT_REPOSITORY='https://github.com/apache/clerezza.git'
export PROJECT_VERSION='201407'
export PROJECT_REF='version-201407'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
