#! /bin/bash
set -euo pipefail
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
curPwd=$(pwd)
export PATH="$curPwd/depot_tools:$PATH"
mkdir chromium && cd chromium
gclient config --name src https://chromium.googlesource.com/chromium/src.git
gclient sync --nohooks
cd src
./build/install-build-deps.sh
gclient runhooks
gn gen out/Default
autoninja -C out/Default chrome
out/Default/chrome
