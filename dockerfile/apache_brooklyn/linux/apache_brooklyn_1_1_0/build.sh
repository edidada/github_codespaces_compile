#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Brooklyn'
export PROJECT_REPOSITORY='https://github.com/apache/brooklyn.git'
export PROJECT_VERSION='apache_brooklyn_1_1_0'
export PROJECT_REF='rel/apache-brooklyn-1.1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
