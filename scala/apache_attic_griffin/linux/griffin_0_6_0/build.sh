#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Griffin'
export PROJECT_REPOSITORY='https://github.com/apache/griffin.git'
export PROJECT_VERSION='griffin_0_6_0'
export PROJECT_REF='griffin-0.6.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
