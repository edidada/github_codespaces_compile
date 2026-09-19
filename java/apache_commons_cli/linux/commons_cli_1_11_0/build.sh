#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons CLI'
export PROJECT_REPOSITORY='https://github.com/apache/commons-cli.git'
export PROJECT_VERSION='commons_cli_1_11_0'
export PROJECT_REF='rel/commons-cli-1.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
