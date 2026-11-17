#!/usr/bin/env bash
set -euo pipefail
export PROJECT_SUBMODULES=1
export PROJECT_BUILD_COMMAND='cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --parallel 2'
export PROJECT_TESTS=0
export PROJECT_NAME='Apache TVM'
export PROJECT_REPOSITORY='https://github.com/apache/tvm.git'
export PROJECT_VERSION='v0.27.0'
export PROJECT_REF='v0.27.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
