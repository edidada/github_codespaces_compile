#! /bin/bash
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
curPwd=$(pwd)
export PATH="$curPwd/depot_tools:$PATH"
mkdir chromium && cd chromium
fetch --nohooks chromium
gclient sync
cd src
./build/install-build-deps.sh
gclient runhooks
gn gen out/Default
autoninja -C out/Default chrome
out/Default/chrome