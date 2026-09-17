#! /bin/bash
cd "$(dirname "$0")"
sudo apt-get update
sudo apt-get install -y libprotobuf-dev
git clone -b v1.39.0 https://github.com/grpc/grpc-java.git
cd grpc-java
./gradlew check :grpc-all:jacocoTestReport
