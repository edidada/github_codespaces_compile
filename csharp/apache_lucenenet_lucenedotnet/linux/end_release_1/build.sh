#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Lucene.Net'
export PROJECT_REPOSITORY='https://github.com/apache/lucenenet.git'
export PROJECT_VERSION='end_release_1'
export PROJECT_REF='end-release-1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
