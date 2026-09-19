#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Apex'
export PROJECT_REPOSITORY='https://github.com/apache/apex-core.git'
export PROJECT_VERSION='3_7_0'
export PROJECT_REF='v3.7.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
