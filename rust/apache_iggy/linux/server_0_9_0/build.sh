#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Iggy'
export PROJECT_REPOSITORY='https://github.com/apache/iggy.git'
export PROJECT_VERSION='server_0_9_0'
export PROJECT_REF='server-0.9.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
