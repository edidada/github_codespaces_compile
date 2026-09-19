#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ivy'
export PROJECT_REPOSITORY='https://github.com/apache/ant-ivy.git'
export PROJECT_VERSION='2_6_0'
export PROJECT_REF='rel/2.6.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
