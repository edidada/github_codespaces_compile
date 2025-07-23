#!/bin/bash
cd "$(dirname "$0")"
wget https://github.com/bazelbuild/bazel/releases/download/8.3.0/bazel-8.3.0-dist.zip
unzip bazel-8.3.0-dist.zip -d ./bazel-8.3.0-dist
cd bazel-8.3.0-dist
wget https://github.com/bazelbuild/bazelisk/releases/download/v1.26.0/bazelisk-linux-amd64
cp bazelisk-linux-amd64 bazelisk
chmod +x bazelisk
 ./bazelisk build //:combine_distfiles
chmod +x compile.sh
./compile.sh