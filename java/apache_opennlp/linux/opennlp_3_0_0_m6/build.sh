#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache OpenNLP'
export PROJECT_REPOSITORY='https://github.com/apache/opennlp.git'
export PROJECT_VERSION='opennlp_3_0_0_m6'
export PROJECT_REF='opennlp-3.0.0-M6'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
