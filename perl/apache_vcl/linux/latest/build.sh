#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache VCL'
export PROJECT_REPOSITORY='https://github.com/apache/vcl.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='find web -type f -name "*.php" -print0 | xargs -0 -n1 php -l && perl -c managementnode/bin/install_perl_libs.pl'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
