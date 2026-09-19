#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache XMLSchema'
export PROJECT_REPOSITORY='https://github.com/apache/ws-xmlschema.git'
export PROJECT_VERSION='xmlschema_2_3_2'
export PROJECT_REF='xmlschema-2.3.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
