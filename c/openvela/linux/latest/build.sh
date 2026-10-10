#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/openvela-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
mkdir -p "$work_root/bin" "$work_root/workspace"

# openvela adds Kconfig extensions beyond the host distro's kconfig-frontends.
# Fetch its official multi-repository QEMU manifest so its matching prebuilt
# build tools are used rather than mixing incompatible host tools.
curl --fail --location --silent --show-error \
  https://storage.googleapis.com/git-repo-downloads/repo \
  --output "$work_root/bin/repo"
chmod +x "$work_root/bin/repo"
export PATH="$work_root/bin:$PATH"

cd "$work_root/workspace"
repo init -u https://github.com/open-vela/manifests.git -b dev -m openvela-qemu.xml
repo sync --current-branch --no-tags -j2
./build.sh nuttx/boards/sim/sim/sim/configs/nsh -j2
test -x nuttx/nuttx
