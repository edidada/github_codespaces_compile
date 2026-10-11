#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/scala-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
git clone --depth=1 https://github.com/scala/scala.git "$work_root"
cd "$work_root"

# Scala's sbt build compiles the compiler, standard library, reflect, and
# their bootstrapping support.  `dist` produces the usable compiler layout.
./sbt -batch -no-colors dist
test -x build/pack/bin/scalac
test -f build/pack/lib/scala-library.jar
