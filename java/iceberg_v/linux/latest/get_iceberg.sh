#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"
git clone --depth 1 --branch apache-iceberg-1.11.0 https://github.com/apache/iceberg.git
cd iceberg

# Iceberg supports modern JDKs, but JDK 17 is the stable build baseline and
# avoids old Gradle bytecode readers encountering Java 21 class files.
if [[ -n "${JAVA_HOME_17_X64:-}" ]]; then
  export JAVA_HOME="$JAVA_HOME_17_X64"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

./gradlew build -x test -x integrationTest
