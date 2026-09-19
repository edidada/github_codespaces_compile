#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons VFS'
export PROJECT_REPOSITORY='https://github.com/apache/commons-vfs.git'
export PROJECT_VERSION='fs_1_0'
export PROJECT_REF='vfs-1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
