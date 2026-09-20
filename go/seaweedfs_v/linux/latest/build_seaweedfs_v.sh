#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 https://github.com/seaweedfs/seaweedfs.git project
cd project
mkdir -p build
go build -o build/weed ./weed
