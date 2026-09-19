#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Solr'
export PROJECT_REPOSITORY='https://github.com/apache/solr.git'
export PROJECT_VERSION='10_0_0'
export PROJECT_REF='releases/solr/10.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
