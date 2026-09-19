#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential 
git clone --depth 1 --recursive --branch release-1.2.0 https://github.com/apache/hudi.git hudi
cd hudi
./mvnw -B -DskipTests -Dcheckstyle.skip -Drat.skip -pl hudi-common -am package
