#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Servicecomb'
export PROJECT_REPOSITORY='https://github.com/apache/servicecomb-java-chassis.git'
export PROJECT_VERSION='3_3_0'
export PROJECT_REF='3.3.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
