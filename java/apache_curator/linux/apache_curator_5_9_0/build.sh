#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Curator'
export PROJECT_REPOSITORY='https://github.com/apache/curator.git'
export PROJECT_VERSION='apache_curator_5_9_0'
export PROJECT_REF='apache-curator-5.9.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
