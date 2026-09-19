#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch 4.47 https://github.com/seaweedfs/seaweedfs.git project
cd project
go build ./weed
