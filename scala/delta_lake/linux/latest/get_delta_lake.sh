#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential 
git clone --depth 1 --recursive  https://github.com/delta-io/delta.git delta_lake
cd delta_lake
./build/sbt compile
