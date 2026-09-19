#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Xalan for Java XSLT Processor'
export PROJECT_REPOSITORY='https://github.com/apache/xalan-java.git'
export PROJECT_VERSION='xsltc_1_1_0'
export PROJECT_REF='xsltc-1_1_0'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
