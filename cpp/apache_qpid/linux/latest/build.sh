#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Qpid'
export PROJECT_REPOSITORY='https://svn.apache.org/repos/asf/qpid/proton/trunk/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
