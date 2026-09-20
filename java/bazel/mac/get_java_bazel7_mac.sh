#!/bin/bash
echo "java version"
java --version
javac --version
cd "$(dirname "$0")"
wget https://github.com/bazelbuild/bazel/releases/download/7.0.0/bazel-7.0.0-dist.zip
unzip bazel-7.0.0-dist.zip -d ./bazel-7.0.0-dist
cd bazel-7.0.0-dist
chmod +x compile.sh
./compile.sh
