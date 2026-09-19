#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Fluo YARN'
export PROJECT_REPOSITORY='https://github.com/apache/accumulo-fluo-yarn.git'
export PROJECT_VERSION='fluo_yarn_1_0_0'
export PROJECT_REF='rel/fluo-yarn-1.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
