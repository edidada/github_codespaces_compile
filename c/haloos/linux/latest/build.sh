#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/haloos-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"
mkdir -p "$work_root/bin" "$work_root/workspace"

curl --fail --location --silent --show-error \
  https://storage.googleapis.com/git-repo-downloads/repo \
  --output "$work_root/bin/repo"
chmod +x "$work_root/bin/repo"
export PATH="$work_root/bin:$PATH"

cd "$work_root/workspace"
repo init -u https://gitee.com/haloos/manifests.git -b master -m vcos.xml
repo sync --current-branch --no-tags -j2

# HaloOS documents rt_demo as the default VCOS demo for the free GCC toolchain.
python3 -m pip install --user loguru
export PATH="$HOME/.local/bin:$PATH"
cd build
python3 haloos_build.py -app_name rt_demo
cd ..
test -d output
