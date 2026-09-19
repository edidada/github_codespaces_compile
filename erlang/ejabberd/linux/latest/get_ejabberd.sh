#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential autoconf libssl-dev libexpat1-dev libyaml-dev
git clone --depth 1 --recursive  https://github.com/processone/ejabberd.git ejabberd
cd ejabberd
./autogen.sh
./configure --enable-all
make -j2
