#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Hadoop'
export PROJECT_REPOSITORY='https://github.com/apache/hadoop.git'
export PROJECT_VERSION='remove_ozone'
export PROJECT_REF='remove-ozone'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
