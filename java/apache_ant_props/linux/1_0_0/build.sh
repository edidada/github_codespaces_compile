#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Props Ant Library'
export PROJECT_REPOSITORY='https://github.com/apache/ant-antlibs-props.git'
export PROJECT_VERSION='1_0_0'
export PROJECT_REF='rel/1.0.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
