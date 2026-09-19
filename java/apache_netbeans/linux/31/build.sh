#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache NetBeans'
export PROJECT_REPOSITORY='https://github.com/apache/netbeans.git'
export PROJECT_VERSION='31'
export PROJECT_REF='31'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
