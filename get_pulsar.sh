#! /bin/bash
cd "$(dirname "$0")"
git clone -b v3.1.2 https://github.com/apache/pulsar.git
cd pulsar
./mvnw install -DskipTests
cd ../
git clone -b v0.5.3 https://github.com/apache/pulsar-client-reactive.git
cd pulsar-client-reactive
./gradlew build