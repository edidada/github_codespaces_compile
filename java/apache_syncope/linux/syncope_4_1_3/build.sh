#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Syncope'
export PROJECT_REPOSITORY='https://github.com/apache/syncope.git'
export PROJECT_VERSION='syncope_4_1_3'
export PROJECT_REF='syncope-4.1.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
