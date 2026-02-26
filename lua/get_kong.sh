#!/bin/bash
cd "$(dirname "$0")"
sudo apt update
sudo apt install -y automake build-essential curl file git libyaml-dev libprotobuf-dev m4 perl pkg-config procps unzip valgrind zlib1g-dev
git clone https://github.com/Kong/kong
cd kong
git checkout master
make build-venv
make dev
sudo make install -y
