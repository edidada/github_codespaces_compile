#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
git clone -b v1.39.0 https://github.com/grpc/grpc-java.git
cd grpc-java
./gradlew check :grpc-all:jacocoTestReport