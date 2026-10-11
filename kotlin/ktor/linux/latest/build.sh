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

# Ktor is Kotlin's flagship asynchronous server/client framework. Build every
# Gradle module and require the JVM server artifact generated from source.
./gradlew --no-daemon build
find . -path '*/build/libs' -name 'ktor-server-core-jvm-*.jar' -print -quit | grep -q .
