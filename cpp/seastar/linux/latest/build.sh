#!/usr/bin/env bash
set -euo pipefail

export PROJECT_NAME='Seastar'
export PROJECT_REPOSITORY='https://github.com/scylladb/seastar.git'
export PROJECT_VERSION='latest'
export PROJECT_REF=''
# Seastar supplies its own dependency installer and Ninja configuration.  Use
# the release target to compile the asynchronous C++ runtime used by Redpanda.
export PROJECT_BUILD_COMMAND='sudo apt-get update && sudo apt-get install -y gcc-14 g++-14 && sudo ./install-dependencies.sh && git clone --depth=1 https://github.com/fmtlib/fmt.git /tmp/seastar-fmt && cmake -S /tmp/seastar-fmt -B /tmp/seastar-fmt/build -DFMT_TEST=OFF -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local && sudo cmake --build /tmp/seastar-fmt/build --target install && CC=gcc-14 CXX=g++-14 ./configure.py --mode=release && ninja -C build/release'

repository_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
exec bash "$repository_root/tools/foundations/build_project.sh"
