#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Asterixdb'
export PROJECT_REPOSITORY='https://github.com/apache/asterixdb.git'
export PROJECT_VERSION='ault_hyrax_next_10'
export PROJECT_REF='vault/hyrax-next@10'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
