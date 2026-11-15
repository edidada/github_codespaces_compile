#!/usr/bin/env bash
set -euo pipefail

repo_root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
cd "$repo_root"

export PROJECT_NAME='Apache APR Portable Runtime'
export PROJECT_REPOSITORY='https://github.com/apache/apr.git'
export PROJECT_VERSION='latest'

exec ./tools/foundations/build_project.sh
