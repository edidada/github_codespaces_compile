#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch v1.4.1 https://github.com/juicedata/juicefs.git project
cd project
go build ./cmd
