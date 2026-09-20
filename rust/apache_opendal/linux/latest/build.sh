#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OpenDAL'
export PROJECT_REPOSITORY='https://github.com/apache/opendal.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_ROOT='core'
export PROJECT_BUILD_COMMAND='if ! command -v protoc >/dev/null; then sudo apt-get update && sudo apt-get install -y protobuf-compiler; fi; cargo test -p opendal --lib'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
