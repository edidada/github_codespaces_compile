#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Livy'
export PROJECT_REPOSITORY='https://github.com/apache/livy.git'
export PROJECT_VERSION='0_9_0_incubating'
export PROJECT_REF='v0.9.0-incubating'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
