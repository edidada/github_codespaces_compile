#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/cats-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
export PATH="$JAVA_HOME/bin:$PATH"

git clone --depth=1 https://github.com/typelevel/cats.git "$work_root"
cd "$work_root"

# Cats is a foundational Scala FP library; compiling all modules verifies its
# core type classes, kernel, syntax and Scala cross-version source layout.
curl -fsSL -o ./sbt https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt
chmod +x ./sbt
./sbt -batch -no-colors compile
# `compile` produces module classes, while published JARs are only made by a
# package task. Check a generated Cats core class from the compiled source.
find core -path '*target*' -path '*/cats/*' -name '*.class' -print -quit | grep -q .
