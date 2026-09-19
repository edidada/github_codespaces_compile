#!/usr/bin/env bash
set -euo pipefail

# GitHub-hosted runners contain SDKs that Chromium does not use. Removing them
# leaves enough disk space for a shallow checkout and a release build.
for path in \
  /usr/share/dotnet \
  /usr/local/lib/android \
  /usr/local/.ghcup \
  /opt/ghc \
  /opt/hostedtoolcache/CodeQL; do
  if [[ -e "$path" ]]; then
    sudo rm -rf --one-file-system "$path"
  fi
done
sudo docker system prune --all --force >/dev/null 2>&1 || true
sudo apt-get clean
df -h /

work_root="${RUNNER_TEMP:-/tmp}/chromium-${GITHUB_RUN_ID:-local}"
mkdir -p "$work_root"
cd "$work_root"

git clone --depth 1 https://chromium.googlesource.com/chromium/tools/depot_tools.git
export PATH="$work_root/depot_tools:$PATH"
export DEPOT_TOOLS_UPDATE=0

mkdir chromium
cd chromium
gclient config --name src https://chromium.googlesource.com/chromium/src.git
gclient sync --nohooks --no-history --shallow --jobs=4
cd src
sudo ./build/install-build-deps.sh --no-prompt --unsupported
gclient runhooks
gn gen out/Release --args='is_debug=false is_component_build=false symbol_level=0 blink_symbol_level=0 v8_symbol_level=0'
autoninja -C out/Release chrome
test -x out/Release/chrome
out/Release/chrome --version
