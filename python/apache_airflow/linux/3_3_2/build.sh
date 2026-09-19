#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Airflow'
export PROJECT_REPOSITORY='https://github.com/apache/airflow.git'
export PROJECT_VERSION='3_3_2'
export PROJECT_REF='3.3.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
