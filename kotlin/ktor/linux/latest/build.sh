#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/ktor-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/ktorio/ktor.git "$work_root"
cd "$work_root"

# Ktor is Kotlin's flagship asynchronous server/client framework. Assemble all
# modules from source. Browser-only test discovery is intentionally outside a
# Linux compilation check and is known to be environment-sensitive upstream.
./gradlew --no-daemon assemble
# Ktor's multiplatform publication names vary; JVM class output directly
# establishes that the source framework compiled on this runner.
find . -path '*/build/classes/*' -name '*.class' -print -quit | grep -q .
