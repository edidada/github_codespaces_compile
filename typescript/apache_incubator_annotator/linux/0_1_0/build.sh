#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Annotator'
export PROJECT_REPOSITORY='https://github.com/apache/incubator-annotator.git'
export PROJECT_VERSION='0_1_0'
export PROJECT_REF='v0.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
