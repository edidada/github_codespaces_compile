#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Metabase'
export PROJECT_REPOSITORY='https://github.com/metabase/metabase.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# The release script invokes shadow-cljs directly, so its Bun dependencies must
# be materialized before the script starts. Pin this to the version declared by
# upstream package.json to keep the lockfile deterministic on hosted runners.
export PROJECT_BUILD_COMMAND='bun install --frozen-lockfile && ./bin/build.sh'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
