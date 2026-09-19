#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons FileUpload'
export PROJECT_REPOSITORY='https://github.com/apache/commons-fileupload.git'
export PROJECT_VERSION='commons_fileupload_2_0_0_m5'
export PROJECT_REF='rel/commons-fileupload-2.0.0-M5'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
