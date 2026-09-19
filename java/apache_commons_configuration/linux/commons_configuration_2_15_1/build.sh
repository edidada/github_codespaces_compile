#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Configuration'
export PROJECT_REPOSITORY='https://github.com/apache/commons-configuration.git'
export PROJECT_VERSION='commons_configuration_2_15_1'
export PROJECT_REF='rel/commons-configuration-2.15.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
