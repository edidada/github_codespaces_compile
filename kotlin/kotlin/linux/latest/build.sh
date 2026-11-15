#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/kotlin-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/JetBrains/kotlin.git "$work_root"
cd "$work_root"

# Kotlin's upstream distribution task builds the compiler, stdlib and the
# surrounding command-line toolchain instead of consuming released binaries.
./gradlew --no-daemon dist
test -x dist/kotlinc/bin/kotlinc
test -f dist/kotlinc/lib/kotlin-stdlib.jar
