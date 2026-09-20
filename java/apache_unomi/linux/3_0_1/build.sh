#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Unomi'
export PROJECT_REPOSITORY='https://github.com/apache/unomi.git'
export PROJECT_VERSION='3_0_1'
export PROJECT_REF='unomi-root-3.0.1'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
