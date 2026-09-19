#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Crunch'
export PROJECT_REPOSITORY='https://github.com/apache/crunch.git'
export PROJECT_VERSION='apache_crunch_1_0_0'
export PROJECT_REF='apache-crunch-1.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
