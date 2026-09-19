#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential erlang-dev elixir libssl-dev
git clone --depth 1 --recursive  https://github.com/emqx/emqx.git emqx
cd emqx
make -j2
