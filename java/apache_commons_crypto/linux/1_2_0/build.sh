#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Crypto'
export PROJECT_REPOSITORY='https://github.com/apache/commons-crypto.git'
export PROJECT_VERSION='1_2_0'
export PROJECT_REF='rel/commons-crypto-1.2.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
