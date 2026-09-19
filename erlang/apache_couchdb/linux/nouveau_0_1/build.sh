#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache CouchDB'
export PROJECT_REPOSITORY='https://github.com/apache/couchdb.git'
export PROJECT_VERSION='nouveau_0_1'
export PROJECT_REF='nouveau-0.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
