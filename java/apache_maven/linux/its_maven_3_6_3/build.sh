#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Maven'
export PROJECT_REPOSITORY='https://github.com/apache/maven-integration-testing.git'
export PROJECT_VERSION='its_maven_3_6_3'
export PROJECT_REF='its-maven-3.6.3'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
