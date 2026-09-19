#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Shiro'
export PROJECT_REPOSITORY='https://github.com/apache/shiro.git'
export PROJECT_VERSION='shiro_root_3_0_1'
export PROJECT_REF='shiro-root-3.0.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
