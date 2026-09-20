#!/usr/bin/env bash
set -euo pipefail
git clone --depth 1 --branch rocketmq-all-4.3.0 https://github.com/apache/rocketmq.git
cd rocketmq
mvn -B -DskipTests clean package
