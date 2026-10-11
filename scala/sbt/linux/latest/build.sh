#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/sbt-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/sbt/sbt.git "$work_root"
cd "$work_root"

# sbt is Scala's reference build tool. Its own multi-module build compiles the
# launcher, command engine, incremental compiler integration and shell tooling.
./sbt -batch -no-colors compile
# Current sbt development builds place module classes under target/out rather
# than publishing a final sbt JAR during `compile`.
find target/out -path '*/sbt/classes/*' -name '*.class' -print -quit | grep -q .
