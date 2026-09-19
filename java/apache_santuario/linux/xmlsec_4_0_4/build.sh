#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Santuario'
export PROJECT_REPOSITORY='https://github.com/apache/santuario-xml-security-java.git'
export PROJECT_VERSION='xmlsec_4_0_4'
export PROJECT_REF='xmlsec-4.0.4'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
