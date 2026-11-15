#!/usr/bin/env bash
set -euo pipefail

work_root="${RUNNER_TEMP:-/tmp}/scala-${GITHUB_RUN_ID:-local}"
rm -rf -- "$work_root"

sudo apt-get update
sudo apt-get install -y openjdk-17-jdk
git clone --depth=1 https://github.com/scala/scala.git "$work_root"
cd "$work_root"

# The Scala repository deliberately does not vendor an sbt launcher. Fetch the
# established sbt-extras launcher so the build remains self-contained.
curl -fsSL -o ./sbt https://raw.githubusercontent.com/paulp/sbt-extras/master/sbt
chmod +x ./sbt

# Compile compiler, standard library and reflect, then make the runnable
# distribution layout documented by the upstream project.
./sbt -batch -no-colors dist/mkPack
test -x build/pack/bin/scalac
test -f build/pack/lib/scala-library.jar
