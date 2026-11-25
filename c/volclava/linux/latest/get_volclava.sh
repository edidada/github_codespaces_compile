#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='volclava'
export PROJECT_REPOSITORY='https://github.com/bytedance/volclava.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# 上游 configure 依次需要 SunRPC(libtirpc)、NIS(libnsl)、Tcl(tcl-dev) 头文件，Ubuntu 默认未装。
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y libtirpc-dev libnsl-dev rpcsvc-proto tcl-dev tk-dev autoconf automake libtool && (./autogen.sh 2>/dev/null || autoreconf -fi); ./configure CPPFLAGS="-I/usr/include/tirpc" LDFLAGS="-ltirpc" && make -j2'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"