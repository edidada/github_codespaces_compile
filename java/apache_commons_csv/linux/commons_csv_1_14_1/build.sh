#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons CSV'
export PROJECT_REPOSITORY='https://github.com/apache/commons-csv.git'
export PROJECT_VERSION='commons_csv_1_14_1'
export PROJECT_REF='rel/commons-csv-1.14.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
