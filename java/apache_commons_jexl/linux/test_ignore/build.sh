#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons JEXL'
export PROJECT_REPOSITORY='https://github.com/apache/commons-jexl.git'
export PROJECT_VERSION='test_ignore'
export PROJECT_REF='test-ignore'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
