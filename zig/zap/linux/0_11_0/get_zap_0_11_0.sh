#! /bin/bash
sudo apt-get update
sudo apt-get install -y gettext autopoint gperf xz-utils
cd "$(dirname "$0")"
ZIG_VERSION=0.15.1
ZIG_DIR="zig-x86_64-linux-${ZIG_VERSION}"
if ! command -v zig >/dev/null 2>&1; then
  curl -fsSLO "https://ziglang.org/download/${ZIG_VERSION}/${ZIG_DIR}.tar.xz"
  tar -xJf "${ZIG_DIR}.tar.xz"
  export PATH="$PWD/${ZIG_DIR}:$PATH"
fi
git clone https://github.com/zigzap/zap.git
cd zap
git checkout v0.11.0
zig build run-hello
