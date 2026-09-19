#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Ignite'
export PROJECT_REPOSITORY='https://github.com/apache/ignite.git'
export PROJECT_VERSION='qaoo_testtag_0606'
export PROJECT_REF='qaoo_testtag_0606'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
