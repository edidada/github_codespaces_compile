#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons BeanUtils'
export PROJECT_REPOSITORY='https://github.com/apache/commons-beanutils.git'
export PROJECT_VERSION='commons_beanutils_2_0_0_m2'
export PROJECT_REF='rel/commons-beanutils-2.0.0-M2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
