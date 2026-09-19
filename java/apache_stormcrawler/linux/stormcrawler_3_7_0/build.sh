#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Stormcrawler'
export PROJECT_REPOSITORY='https://github.com/apache/stormcrawler.git'
export PROJECT_VERSION='stormcrawler_3_7_0'
export PROJECT_REF='stormcrawler-3.7.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
