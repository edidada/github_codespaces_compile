#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Bigtop'
export PROJECT_REPOSITORY='https://github.com/apache/bigtop.git'
export PROJECT_VERSION='3_2_0'
export PROJECT_REF='release-3.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
