#!/usr/bin/env bash
set -euo pipefail
if ! command -v go >/dev/null 2>&1; then
  brew install go
fi
git clone --depth 1 --branch 4.47 https://github.com/seaweedfs/seaweedfs.git project
cd project
go build ./weed
