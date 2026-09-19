#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Lang'
export PROJECT_REPOSITORY='https://github.com/apache/commons-lang.git'
export PROJECT_VERSION='commons_lang_3_20_0'
export PROJECT_REF='rel/commons-lang-3.20.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
