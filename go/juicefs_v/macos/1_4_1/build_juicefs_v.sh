#!/usr/bin/env bash
set -euo pipefail
if ! command -v go >/dev/null 2>&1; then
  brew install go
fi
git clone --depth 1 --branch v1.4.1 https://github.com/juicedata/juicefs.git project
cd project
go build ./cmd
