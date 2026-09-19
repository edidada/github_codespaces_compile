#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential erlang-dev erlang-parsetools elixir xsltproc zip unzip
git clone --depth 1 --recursive  https://github.com/rabbitmq/rabbitmq-server.git rabbitmq
cd rabbitmq
make -j2
