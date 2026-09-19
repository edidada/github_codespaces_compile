#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Tomcat'
export PROJECT_REPOSITORY='https://github.com/apache/tomcat.git'
export PROJECT_VERSION='11_0_26'
export PROJECT_REF='11.0.26'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
