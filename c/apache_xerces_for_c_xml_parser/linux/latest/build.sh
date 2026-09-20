#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Xerces for C++ XML Parser'
export PROJECT_REPOSITORY='https://svn.apache.org/repos/asf/xerces/c/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
