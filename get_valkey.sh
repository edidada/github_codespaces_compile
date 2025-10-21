#! /bin/bash
cd "$(dirname "$0")"
git clone https://github.com/valkey-io/valkey.git
cd valkey
make