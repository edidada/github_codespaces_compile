#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Commons Jelly'
export PROJECT_REPOSITORY='https://github.com/apache/commons-jelly.git'
export PROJECT_VERSION='commons_jelly_tags_xml_1_1'
export PROJECT_REF='commons-jelly-tags-xml-1.1'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
