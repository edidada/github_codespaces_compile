#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Redpanda'
export PROJECT_REPOSITORY='https://github.com/redpanda-data/redpanda.git'
export PROJECT_VERSION='26_2_2'
export PROJECT_REF='v26.2.2'
# Redpanda documents this dependency bootstrap followed by a release Bazel build.
# Building the complete graph validates the broker rather than only its rpk client.
export PROJECT_BUILD_COMMAND='sudo ./bazel/install-deps.sh && bazel build --config=release //...'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
