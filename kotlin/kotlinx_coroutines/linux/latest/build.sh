#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/kotlinx-coroutines-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/Kotlin/kotlinx.coroutines.git "$work_root"
cd "$work_root"

# Build the multi-platform coroutine runtime and its JVM implementation from
# source; this is Kotlin's principal asynchronous-concurrency library.
./gradlew --no-daemon build
find . -path '*/build/libs' -name 'kotlinx-coroutines-core-*.jar' -print -quit | grep -q .
