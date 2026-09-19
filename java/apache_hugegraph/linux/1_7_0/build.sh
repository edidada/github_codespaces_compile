#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Hugegraph'
export PROJECT_REPOSITORY='https://github.com/apache/hugegraph.git'
export PROJECT_VERSION='1_7_0'
export PROJECT_REF='1.7.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
