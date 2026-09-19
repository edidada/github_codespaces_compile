#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache NiFi'
export PROJECT_REPOSITORY='https://github.com/apache/nifi.git'
export PROJECT_VERSION='nifi_2_12_0'
export PROJECT_REF='rel/nifi-2.12.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
