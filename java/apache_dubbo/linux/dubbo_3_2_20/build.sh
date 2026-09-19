#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Dubbo'
export PROJECT_REPOSITORY='https://github.com/apache/dubbo.git'
export PROJECT_VERSION='dubbo_3_2_20'
export PROJECT_REF='dubbo-3.2.20'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
