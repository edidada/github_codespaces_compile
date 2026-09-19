#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Validator'
export PROJECT_REPOSITORY='https://github.com/apache/commons-validator.git'
export PROJECT_VERSION='commons_validator_1_11_0'
export PROJECT_REF='rel/commons-validator-1.11.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
