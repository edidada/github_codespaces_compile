#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OpenMeetings'
export PROJECT_REPOSITORY='https://github.com/apache/openmeetings.git'
export PROJECT_VERSION='9_1_0'
export PROJECT_REF='9.1.0'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
