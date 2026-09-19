#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Directory LDAP API'
export PROJECT_REPOSITORY='https://github.com/apache/directory-ldap-api.git'
export PROJECT_VERSION='2_1_8'
export PROJECT_REF='2.1.8'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
