#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Velox'
export PROJECT_REPOSITORY='https://github.com/facebookincubator/velox.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# The project-maintained Ubuntu bootstrap installs its third-party dependencies;
# the release target compiles the vectorized C++ execution engine.
export PROJECT_BUILD_COMMAND='sudo ./scripts/setup-ubuntu.sh && make release'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
