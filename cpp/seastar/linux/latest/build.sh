#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Seastar'
export PROJECT_REPOSITORY='https://github.com/scylladb/seastar.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Seastar supplies its own dependency installer and Ninja configuration.  Use
# the release target to compile the asynchronous C++ runtime used by Redpanda.
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo ./install-dependencies.sh && ./configure.py --mode=release && ninja -C build/release'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
