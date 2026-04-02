#! /bin/bash
cd "$(dirname "$0")"
git clone -b 3.8.1 https://github.com/quarkusio/quarkus.git
cd quarkus
./mvnw clean package  -DskipTests
