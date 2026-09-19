#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y git curl build-essential maven
git clone --depth 1 --recursive  https://github.com/apache/hudi.git hudi
cd hudi
mvn -B -DskipTests -Dcheckstyle.skip -Drat.skip -pl hudi-common -am package
