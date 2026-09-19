#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache SkyWalking'
export PROJECT_REPOSITORY='https://github.com/apache/skywalking.git'
export PROJECT_VERSION='11_0_0'
export PROJECT_REF='v11.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
