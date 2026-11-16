#!/usr/bin/env bash
set -euo pipefail
export PROJECT_TESTS=0
export PROJECT_BUILD_COMMAND='command -v protoc >/dev/null || { sudo apt-get update; sudo apt-get install -y protobuf-compiler; }; cargo build --workspace --bins --lib'
export PROJECT_NAME='Apache DataFusion'
export PROJECT_REPOSITORY='https://github.com/apache/datafusion.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
