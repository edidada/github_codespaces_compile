#! /bin/bash
cd "$(dirname "$0")"
git clone -b 3.1.11 https://github.com/apache/dubbo.git
cd dubbo
./mvnw clean package  -DskipTests
