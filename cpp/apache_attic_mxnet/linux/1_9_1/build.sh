#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache MXNet'
export PROJECT_REPOSITORY='https://github.com/apache/mxnet.git'
export PROJECT_VERSION='1_9_1'
export PROJECT_REF='1.9.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
