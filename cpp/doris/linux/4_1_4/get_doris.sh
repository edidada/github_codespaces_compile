#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential openjdk-17-jdk maven cmake ninja-build ccache byacc
git clone --depth 1 --recursive --branch 4.1.4 https://github.com/apache/doris.git doris
cd doris
bash build.sh --fe
