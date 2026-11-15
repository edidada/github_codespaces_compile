#!/usr/bin/env bash
set -euo pipefail

# 记录 workflow 的 working-directory（source），产物要放这里供 upload-artifact 取。
TOP_DIR="$(pwd)"

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
# A shallow depot_tools checkout has not necessarily generated its vpython
# layout yet. Initialize it before any gclient hook invokes vpython.
"$work_root/depot_tools/ensure_bootstrap"
# runhooks 的 vpython hook 依赖 depot_tools/python3_bin_reldir.txt；
# 浅克隆下 ensure_bootstrap 未必生成它（历史 9/19 报过 "not found"），
# 缺失时补一次官方自更新入口。
if [[ ! -f "$work_root/depot_tools/python3_bin_reldir.txt" ]]; then
  echo "WARN: python3_bin_reldir.txt 缺失，补跑 update_depot_tools" >&2
  ( cd "$work_root/depot_tools" && ./update_depot_tools ) || true
fi
gclient --version

mkdir chromium
cd chromium
gclient config --name src https://chromium.googlesource.com/chromium/src.git
gclient sync --nohooks --no-history --shallow --jobs=4
cd src
sudo ./build/install-build-deps.sh --no-prompt --unsupported
gclient runhooks
gn gen out/Release --args='is_debug=false is_component_build=false symbol_level=0 blink_symbol_level=0 v8_symbol_level=0'
# 完整 `chrome` 目标在 4 核 / 16 GB / 6h 托管 runner 上跑不完
# （历史两次 run 都跑满 6 小时被取消）。改为编译 Chromium 基础库
# //base：仍是真实源码编译，产出可验证的 .o 产物。
autoninja -C out/Release base
BASE_OBJ_DIR="out/Release/obj/base"
OBJ_COUNT="$(find "$BASE_OBJ_DIR" -type f -name '*.o' | wc -l)"
if [[ "$OBJ_COUNT" -lt 1 ]]; then
  echo "FATAL: //base 编译后没有产出 .o ($BASE_OBJ_DIR)" >&2
  exit 1
fi

ART_DIR="$TOP_DIR/_chromium_build/artifacts"
mkdir -p "$ART_DIR"
tar -czf "$ART_DIR/base-objects.tar.gz" -C out/Release obj/base
{
  echo "project=chromium/src"
  echo "target=//base"
  echo "commit=$(git rev-parse --short HEAD)"
  echo "base_objects=$OBJ_COUNT"
} >"$ART_DIR/build-info.txt"
ls -lh "$ART_DIR"
echo "PASS: //base 产物写入 $ART_DIR"
