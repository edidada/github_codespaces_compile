#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Nutch'
export PROJECT_REPOSITORY='https://github.com/apache/nutch.git'
export PROJECT_VERSION='2_4'
export PROJECT_REF='release-2.4'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
