#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache InLong'
export PROJECT_REPOSITORY='https://github.com/apache/inlong.git'
export PROJECT_VERSION='inlong_sdk_dataproxy_sdk_twins_dataproxy_sdk_golang_v1_0_8'
export PROJECT_REF='inlong-sdk/dataproxy-sdk-twins/dataproxy-sdk-golang/v1.0.8'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
