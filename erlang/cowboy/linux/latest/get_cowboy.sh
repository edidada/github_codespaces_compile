#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential erlang-dev erlang-nox rebar3
git clone --depth 1 --recursive  https://github.com/ninenines/cowboy.git cowboy
cd cowboy
rebar3 compile
