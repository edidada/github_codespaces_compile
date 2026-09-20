#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential 
git clone --depth 1 --recursive  https://github.com/trinodb/trino.git trino
cd trino
./mvnw -B -DskipTests -Dair.check.skip-all=true -pl core/trino-main -am package
