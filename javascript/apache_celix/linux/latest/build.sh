#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Celix'
export PROJECT_REPOSITORY='https://github.com/apache/celix.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''

export PROJECT_BUILD_COMMAND='sudo apt-get update -qq && sudo apt-get install -y -qq libzip-dev libjansson-dev libcurl4-openssl-dev libssl-dev libffi-dev libczmq-dev uuid-dev && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=OFF && cmake --build build --parallel 2'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
