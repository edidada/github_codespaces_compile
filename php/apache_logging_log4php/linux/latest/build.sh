#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4php'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/logging/log4php/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='docker run --rm -v "$PWD:/work" -w /work php:7.4-cli bash -euc '\''curl -fsSL https://phar.phpunit.de/phpunit-5.7.27.phar -o /tmp/phpunit.phar; php /tmp/phpunit.phar -c phpunit.xml'\'''
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
