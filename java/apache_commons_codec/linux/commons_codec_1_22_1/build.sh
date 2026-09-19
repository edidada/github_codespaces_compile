#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Codec'
export PROJECT_REPOSITORY='https://github.com/apache/commons-codec.git'
export PROJECT_VERSION='commons_codec_1_22_1'
export PROJECT_REF='rel/commons-codec-1.22.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
