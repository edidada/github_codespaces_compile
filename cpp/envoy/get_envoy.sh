#! /bin/bash
cd "$(dirname "$0")"
git clone -b v1.29.1 https://github.com/envoyproxy/envoy.git
cd envoy
bazel build -c opt envoy