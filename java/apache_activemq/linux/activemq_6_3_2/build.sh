#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ActiveMQ'
export PROJECT_REPOSITORY='https://github.com/apache/activemq.git'
export PROJECT_VERSION='activemq_6_3_2'
export PROJECT_REF='activemq-6.3.2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
