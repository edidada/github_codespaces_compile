#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Singa'
export PROJECT_REPOSITORY='https://github.com/apache/singa.git'
export PROJECT_VERSION='3_0_0'
export PROJECT_REF='3.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
