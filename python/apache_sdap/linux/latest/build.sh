#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_NAME='Apache Sdap'
export PROJECT_REPOSITORY='https://github.com/apache/sdap-nexus.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='grep -rl 'cassandra-driver==3.24.0' --include=*.txt --include=*.py . | xargs -r sed -i 's/cassandra-driver==3.24.0/cassandra-driver/' ; python -m pip install --upgrade pip build setuptools wheel && python -m pip install -e . && python -m build --wheel'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
