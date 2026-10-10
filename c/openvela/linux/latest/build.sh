#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/openvela-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
mkdir -p "$work_root"

# Build the official openvela NuttX kernel and companion apps tree using the
# portable host simulator configuration.  This exercises Xiaomi's maintained
# openvela forks without requiring a physical AIoT board.
git clone --depth=1 --branch dev https://github.com/open-vela/nuttx.git "$work_root/nuttx"
git clone --depth=1 --branch dev https://github.com/open-vela/nuttx-apps.git "$work_root/apps"
cd "$work_root/nuttx"
./tools/configure.sh sim:nsh
make -j2
test -x nuttx
