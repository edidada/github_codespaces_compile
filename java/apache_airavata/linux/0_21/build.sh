#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Airavata'
export PROJECT_REPOSITORY='https://github.com/apache/airavata.git'
export PROJECT_VERSION='0_21'
export PROJECT_REF='v0.21'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
