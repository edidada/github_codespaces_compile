#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache PouchDB'
export PROJECT_REPOSITORY='https://github.com/apache/pouchdb.git'
export PROJECT_VERSION='9_0_0'
export PROJECT_REF='9.0.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
