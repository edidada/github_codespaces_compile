#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DOXYFILE="$SCRIPT_DIR/../../Doxyfile"
cd "$SCRIPT_DIR"
sudo apt update
sudo apt-get install -y git g++ make libssl-dev libgflags-dev libprotobuf-dev libprotoc-dev protobuf-compiler libleveldb-dev doxygen
sudo apt-get install -y libsnappy-dev
git clone --depth 1 --branch 1.13.0 https://github.com/apache/brpc.git
cd brpc
sh config_brpc.sh --headers=/usr/include --libs=/usr/lib
make -j4
doxygen "$DOXYFILE"
cat docs/html/index.html
