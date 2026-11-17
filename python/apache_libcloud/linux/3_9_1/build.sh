#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Libcloud'
export PROJECT_REPOSITORY='https://github.com/apache/libcloud.git'
export PROJECT_VERSION='3_9_1'
export PROJECT_REF='v3.9.1'
export PROJECT_BUILD_COMMAND='sudo apt-get update -qq && sudo apt-get install -y -qq libvirt-dev pkg-config && python -m pip install --upgrade pip build && python -m pip install -e . && python -m build'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
