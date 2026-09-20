#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential xsltproc zip unzip
git clone --depth 1 --recursive  https://github.com/rabbitmq/rabbitmq-server.git rabbitmq
cd rabbitmq
# rabbitmq_cli consumes rabbit_common/ebin while it is being generated;
# keep this target serial to avoid the parallel dependency race.
make -j1
