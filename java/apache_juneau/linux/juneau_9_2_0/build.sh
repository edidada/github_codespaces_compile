#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Juneau'
export PROJECT_REPOSITORY='https://github.com/apache/juneau.git'
export PROJECT_VERSION='juneau_9_2_0'
export PROJECT_REF='juneau-9.2.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
