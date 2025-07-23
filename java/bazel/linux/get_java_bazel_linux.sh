#!/bin/bash
cd "$(dirname "$0")"
wget https://github.com/bazelbuild/bazel/releases/download/8.3.0/bazel-8.3.0-dist.zip
unzip bazel-8.3.0-dist.zip -d ./bazel-8.3.0-dist
ls
pwd
cd bazel-8.3.0-dist
ls
pwd
 ./bazelisk build //:combine_distfiles