#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Rya'
export PROJECT_REPOSITORY='https://github.com/apache/rya.git'
export PROJECT_VERSION='rya_incubating_4_0_0'
export PROJECT_REF='rel/rya-incubating-4.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
