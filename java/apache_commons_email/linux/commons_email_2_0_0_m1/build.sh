#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Email'
export PROJECT_REPOSITORY='https://github.com/apache/commons-email.git'
export PROJECT_VERSION='commons_email_2_0_0_m1'
export PROJECT_REF='rel/commons-email-2.0.0-M1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
