#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4php'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/logging/log4php/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='command -v php >/dev/null || { sudo apt-get update; sudo apt-get install -y php-cli; }; find src/main -name "*.php" -print0 | xargs -0 -n1 php -l > /dev/null && echo PHP_LINT_OK'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
