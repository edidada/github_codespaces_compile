#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Training'
export PROJECT_REPOSITORY='https://github.com/apache/training.git'
export PROJECT_VERSION='training_tools_1_4_0'
export PROJECT_REF='training-tools-1.4.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
