#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Proxy (Dormant)'
export PROJECT_REPOSITORY='https://github.com/apache/commons-proxy.git'
export PROJECT_VERSION='sandbox'
export PROJECT_REF='sandbox'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
