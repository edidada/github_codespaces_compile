#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$PWD/depot_tools:$PATH"
gclient --version
mkdir webrtc-checkout
cd webrtc-checkout
fetch --nohooks webrtc
cd src
git checkout -b m153 refs/remotes/branch-heads/8010
gclient sync --reset --force --delete_unversioned_trees --no-history
gn gen out/Release --args='is_debug=false rtc_include_tests=false rtc_build_examples=false'
autoninja -C out/Release webrtc
