#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Rocketmq'
export PROJECT_REPOSITORY='https://github.com/apache/rocketmq.git'
export PROJECT_VERSION='rocketmq_all_5_5_1'
export PROJECT_REF='rocketmq-all-5.5.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
