#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='EROFS Utils'
export PROJECT_REPOSITORY='https://github.com/erofs/erofs-utils.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y liblz4-dev libselinux1-dev uuid-dev zlib1g-dev libfuse-dev pkg-config && ./autogen.sh && ./configure --enable-lz4 --enable-fuse && make -j2 && find . -maxdepth 2 -type f -perm -u+x -newer configure | head -20'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"