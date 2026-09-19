#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache MetaModel'
export PROJECT_REPOSITORY='https://github.com/apache/metamodel.git'
export PROJECT_VERSION='metamodel_5_3_3'
export PROJECT_REF='MetaModel-5.3.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
