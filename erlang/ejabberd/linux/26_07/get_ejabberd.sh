#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential autoconf erlang-dev erlang-nox libssl-dev libexpat1-dev libyaml-dev
git clone --depth 1 --recursive --branch 26.07 https://github.com/processone/ejabberd.git ejabberd
cd ejabberd
./autogen.sh
./configure --enable-all
make -j2
