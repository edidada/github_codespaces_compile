#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
git clone --depth 1 --branch v0.57.0 https://github.com/fatedier/frp.git
cd frp
go build ./cmd/...
