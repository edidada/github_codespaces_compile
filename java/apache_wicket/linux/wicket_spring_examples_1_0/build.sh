#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Wicket'
export PROJECT_REPOSITORY='https://github.com/apache/wicket.git'
export PROJECT_VERSION='wicket_spring_examples_1_0'
export PROJECT_REF='wicket-spring-examples-1.0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
