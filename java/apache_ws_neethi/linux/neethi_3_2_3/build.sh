#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Neethi'
export PROJECT_REPOSITORY='https://github.com/apache/ws-neethi.git'
export PROJECT_VERSION='neethi_3_2_3'
export PROJECT_REF='neethi-3.2.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
