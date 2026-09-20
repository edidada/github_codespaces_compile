#! /bin/bash
cd "$(dirname "$0")"
git clone https://skia.googlesource.com/skia
cd skia
python2 tools/gn --args='is_official_build=true'
ninja -C out/Release
bazel build //...