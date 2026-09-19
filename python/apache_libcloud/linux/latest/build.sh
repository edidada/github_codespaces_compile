#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Libcloud'
export PROJECT_REPOSITORY='https://github.com/apache/libcloud.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='python -m pip install --upgrade tox && tox -e py3.12'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
