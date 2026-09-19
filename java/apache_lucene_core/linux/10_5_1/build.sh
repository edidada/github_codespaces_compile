#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Lucene Core'
export PROJECT_REPOSITORY='https://github.com/apache/lucene.git'
export PROJECT_VERSION='10_5_1'
export PROJECT_REF='releases/lucene/10.5.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
