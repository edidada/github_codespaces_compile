#!/usr/bin/env bash
set -euo pipefail
export PROJECT_NAME='Apache log4cxx'
export PROJECT_REPOSITORY='https://github.com/apache/logging-log4cxx.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y libapr1-dev libaprutil1-dev && cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTING=ON && cmake --build build --parallel 2 && ctest --test-dir build --output-on-failure'
repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec "$repository_root/tools/foundations/build_project.sh"
