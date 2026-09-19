#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential maven
git clone --depth 1 --recursive --branch release-2.0.0 https://github.com/apache/paimon.git paimon
cd paimon
mvn -B -DskipTests -Dcheckstyle.skip -Drat.skip -pl paimon-core -am package
