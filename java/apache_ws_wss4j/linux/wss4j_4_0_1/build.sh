#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache WSS4J'
export PROJECT_REPOSITORY='https://github.com/apache/ws-wss4j.git'
export PROJECT_VERSION='wss4j_4_0_1'
export PROJECT_REF='wss4j-4.0.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
