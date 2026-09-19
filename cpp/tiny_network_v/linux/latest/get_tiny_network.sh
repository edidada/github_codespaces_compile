#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install cmake -y
git clone https://github.com/Shangyizhou/A-Tiny-Network-Library.git
cd A-Tiny-Network-Library
sed -i '1i#include <string>' src/http/HttpResponse.h
chmod +x build.sh
./build.sh
