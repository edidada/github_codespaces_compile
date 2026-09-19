#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4php'
export PROJECT_REPOSITORY='http://svn.apache.org/repos/asf/logging/log4php/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='curl -fsSL https://phar.phpunit.de/phpunit-4.8.36.phar -o /tmp/phpunit-log4php.phar && docker run --rm -v "$PWD:/work" -v /tmp/phpunit-log4php.phar:/tmp/phpunit.phar:ro -w /work php:5.6-cli php /tmp/phpunit.phar -c phpunit.xml'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
