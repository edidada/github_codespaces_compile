#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Rat'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/creadur/rat/trunk/'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
