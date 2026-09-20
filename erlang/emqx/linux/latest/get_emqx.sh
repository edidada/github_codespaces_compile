#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential libssl-dev libkrb5-dev libsasl2-dev rustc cargo
git clone --depth 1 --recursive  https://github.com/emqx/emqx.git emqx
cd emqx
make -j2
