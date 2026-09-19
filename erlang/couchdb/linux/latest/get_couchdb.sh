#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential erlang-nox erlang-dev libicu-dev libmozjs-115-dev libcurl4-openssl-dev
git clone --depth 1 --recursive  https://github.com/apache/couchdb.git couchdb
cd couchdb
./configure --disable-docs
make -j2 release
