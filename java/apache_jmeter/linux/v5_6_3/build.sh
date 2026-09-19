#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache JMeter'
export PROJECT_REPOSITORY='https://github.com/apache/jmeter.git'
export PROJECT_VERSION='v5_6_3'
export PROJECT_REF='rel/v5.6.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
