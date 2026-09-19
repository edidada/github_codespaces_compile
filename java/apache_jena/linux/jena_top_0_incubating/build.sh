#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Jena'
export PROJECT_REPOSITORY='https://github.com/apache/jena.git'
export PROJECT_VERSION='jena_top_0_incubating'
export PROJECT_REF='jena-top-0-incubating'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
