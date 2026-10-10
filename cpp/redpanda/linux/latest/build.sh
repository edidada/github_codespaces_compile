#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Redpanda'
export PROJECT_REPOSITORY='https://github.com/redpanda-data/redpanda.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# This is Redpanda's documented Linux bootstrap and release build.  Building
# //... compiles the broker and every first-party Bazel target rather than only
# the rpk client utility.
export PROJECT_BUILD_COMMAND='sudo ./bazel/install-deps.sh && bazel build --config=release //...'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
