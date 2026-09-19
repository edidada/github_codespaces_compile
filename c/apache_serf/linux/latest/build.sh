#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache Serf'
export PROJECT_REPOSITORY='https://svn.apache.org/repos/asf/serf/trunk'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y libapr1-dev libaprutil1-dev libssl-dev zlib1g-dev && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON && cmake --build build --parallel 2 && ctest --test-dir build --output-on-failure'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
