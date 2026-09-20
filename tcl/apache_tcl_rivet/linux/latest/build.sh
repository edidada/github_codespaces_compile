#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache rivet'
export PROJECT_REPOSITORY='https://github.com/apache/tcl-rivet.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y tcl-dev apache2-dev && autoreconf -fi && ./configure --with-tcl=/usr/lib/tcl8.6 && make && make check'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
