#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Sdap'
export PROJECT_REPOSITORY='https://github.com/apache/sdap-nexus.git'
export PROJECT_VERSION='distributed_0_4_5a40'
export PROJECT_REF='distributed.0.4.5a40'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
