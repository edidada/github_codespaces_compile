#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Reqsign'
export PROJECT_REPOSITORY='https://github.com/apache/opendal-reqsign.git'
export PROJECT_VERSION='0_20_6'
export PROJECT_REF='v0.20.6'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
