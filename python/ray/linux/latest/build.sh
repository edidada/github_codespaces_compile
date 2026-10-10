#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Ray'
export PROJECT_REPOSITORY='https://github.com/ray-project/ray.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Ray's editable source installation invokes its Bazel-backed native build and
# produces the Python bindings used by the distributed runtime.
export PROJECT_BUILD_COMMAND='python -m pip install --upgrade pip && python -m pip install -v -e .'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
