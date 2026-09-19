#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Cassandra'
export PROJECT_REPOSITORY='https://github.com/apache/cassandra.git'
export PROJECT_VERSION='cassandra_5_0_9'
export PROJECT_REF='cassandra-5.0.9'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
