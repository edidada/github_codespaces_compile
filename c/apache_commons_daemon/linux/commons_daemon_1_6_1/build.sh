#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Daemon'
export PROJECT_REPOSITORY='https://github.com/apache/commons-daemon.git'
export PROJECT_VERSION='commons_daemon_1_6_1'
export PROJECT_REF='rel/commons-daemon-1.6.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
