#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache ZooKeeper'
export PROJECT_REPOSITORY='https://github.com/apache/zookeeper.git'
export PROJECT_VERSION='zookeeper'
export PROJECT_REF='zookeeper-'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
