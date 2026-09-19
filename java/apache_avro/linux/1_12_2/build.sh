#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Avro'
export PROJECT_REPOSITORY='https://github.com/apache/avro.git'
export PROJECT_VERSION='1_12_2'
export PROJECT_REF='release-1.12.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
