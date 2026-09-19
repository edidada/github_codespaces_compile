#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential erlang-nox erlang-dev libicu-dev libmozjs-115-dev libcurl4-openssl-dev
git clone --depth 1 --recursive --branch 3.5.2 https://github.com/apache/couchdb.git couchdb
cd couchdb
./configure --disable-docs
make -j2 release
