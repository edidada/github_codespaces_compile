#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tinkerpop'
export PROJECT_REPOSITORY='https://github.com/apache/tinkerpop.git'
export PROJECT_VERSION='gremlin_go_v3_8_2'
export PROJECT_REF='gremlin-go/v3.8.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
