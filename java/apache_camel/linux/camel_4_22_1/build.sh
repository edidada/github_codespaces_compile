#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Camel'
export PROJECT_REPOSITORY='https://github.com/apache/camel.git'
export PROJECT_VERSION='camel_4_22_1'
export PROJECT_REF='camel-4.22.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
