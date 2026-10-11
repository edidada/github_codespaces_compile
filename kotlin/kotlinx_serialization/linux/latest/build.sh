#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/kotlinx-serialization-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/Kotlin/kotlinx.serialization.git "$work_root"
cd "$work_root"

# Build Kotlin's serialization compiler plugin and its core runtime modules.
./gradlew --no-daemon build
find . -path '*/build/libs' -name 'kotlinx-serialization-core-jvm-*.jar' -print -quit | grep -q .
