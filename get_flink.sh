#! /bin/bash
cd "$(dirname "$0")"
git clone -b release-1.18.1 https://github.com/apache/flink.git
cd flink
./mvnw clean package -DskipTests